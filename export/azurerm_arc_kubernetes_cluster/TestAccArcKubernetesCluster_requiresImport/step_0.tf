
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033826829397"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033826829397"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-240112033826829397"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033826829397"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-240112033826829397"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7890!"
  provision_vm_agent              = false
  allow_extension_operations      = false
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-240112033826829397"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxCl3r7z9BwuR/0N2uqECoEETJ+J/yVPEO62S7l1jw5LrLqQT49FFJ9wmyPM6FZDp/TkccHkbJPYMq762cD0/KRn4yxzizzYguBCD+2p6LnbkIg23kWgJU2OaMuOepwZ1ZY1ue0EQGq06y0/CV1GJN/bbOWVxxtTrWYMXbHX8WkY2RzCzgupNH5giUNwXW0yjRY4DqlgJLzSvxxfGQHSEaq4khy8F+zeXgpxI7enXvqnRGiJh+EnlpckaJMihcJpfH+zho26aePokVhtk49/6xdWYL17JxVV1ssiJFD9h7VOheH6Sv5wHugp5z8Dl8TzMKVFTmJnup0/7IbVooWfZPF67jXCdiaesmt2e3poA9yrE3LdsEJzU4+0u3kkHLFdE11f2gdpjI49rF+CX1mS1HZXmtJHSvtBXZmcRRed03uPlu263HPQssTOlE1GOz2j5HaT3TbeAjG1CYvreBW0zro8+UE1wCQO5mpFoWU4a5sYzKl/WCLnjzEZTp3SgpX5uwJERf7Odnc4yJBaC7tcvU8t31opdGNY6rgduAAApKChAs2X4E1/6ws2cYDvULtrK5ui8UJoluvnuz6J38Y84gOiHM71e+p1shfqj/fzpRNI53x0aNh/R7J9FNrKxwudRiq5c3ZSZo37EEv1FOzgHxb15uHqKba9rrVFWAWSxTGsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7890!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033826829397"
    location            = azurerm_resource_group.test.location
    tenant_id           = "ARM_TENANT_ID"
    working_dir         = "/home/adminuser"
  })
  destination = "/home/adminuser/install_agent.sh"
}

provisioner "file" {
  source      = "testdata/install_agent.py"
  destination = "/home/adminuser/install_agent.py"
}

provisioner "file" {
  source      = "testdata/kind.yaml"
  destination = "/home/adminuser/kind.yaml"
}

provisioner "file" {
  content     = <<EOT
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----

EOT
  destination = "/home/adminuser/private.pem"
}

provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/\r$//' /home/adminuser/install_agent.sh",
    "sudo chmod +x /home/adminuser/install_agent.sh",
    "bash /home/adminuser/install_agent.sh > /home/adminuser/agent_log",
  ]
}


  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
