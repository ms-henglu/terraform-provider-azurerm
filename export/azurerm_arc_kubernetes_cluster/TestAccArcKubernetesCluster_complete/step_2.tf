
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014505141374"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014505141374"
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
  name                = "acctestpip-230721014505141374"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014505141374"
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
  name                            = "acctestVM-230721014505141374"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5706!"
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
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-230721014505141374"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0oLdpBDea7mZqkYyQMW+wjl4XmfIszm4jXySxCXqSbF1yeRxqsOZL1AuKKGsT6dQuEIOwQV4gynO85TEjjikLuLk0orKFAAvJSPWLENBfrrG52goK7TRV/x1Cc1ZTkNJeGrdPxvP7+vWnO5heFyXi5Y2xsOK1dAoWYNJwcgANiVbTu3SyVAav8xbUj2c+DSd3gm91KCFLL8F9j87hQtUA9WFRipTy4/lkR/eISD7F7tnllKJOpxCO1+MwNDAFa2b8EhhUCYpSbKqP5tI7vjVqE0iLVXZMG9s9arqkNy6BmIRJr6ZS5LyVoGuuXb1RfrnQMKq69QUSCklhawXI7WadrI9GzQ7LNE0XuGhCJwvxZjeuvnCrrqws2Dudkv0nkzSwHRaSLBFL6JKQDCT1krQ1cJvfj/nxEbeXN33r6hZaoXJG41+Unx+fyjG7+BaVWro8n5HL2uABbseZqGWPCjFd/7LDOEOw/zQoKC3c+bnQK7MRau5Ar5Jba4vtf/0up78RY3kSDSMN7cdD8vmCrr9M749EOanDmPI0Q7XFU2XTDqOoKgvY4sCX6J72SqEXrJ4/v/AcOra4k6bvhdxt3qNcV6yVtYz2YsgcMBA8WIAXdRrCOXlN2zEj3ZlNuABjjbeUEG6aZNKLnkFd+EnfEBOWODRkeFkPRZ4QehHhoyrStMCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "TestUpdate"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5706!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014505141374"
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
