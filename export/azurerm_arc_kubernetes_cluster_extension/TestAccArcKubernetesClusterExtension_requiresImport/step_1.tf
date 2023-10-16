
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033344455795"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033344455795"
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
  name                = "acctestpip-231016033344455795"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033344455795"
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
  name                            = "acctestVM-231016033344455795"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1205!"
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
  name                         = "acctest-akcc-231016033344455795"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAr9MKv5nMaDQT+6WTYuUNnTRJ20l8jhzcn6fdJOGWZp76LhjcNe+YZ6xNa3hJOVxI1EgJY+n1c/uMSbcMozIit7P6S1y75slL2UtjJp34FGfKcRDETMympbLjToZ54gFsJUuqO2y9LIO8Z6x3DYMKU7DnNyBOibgmjXQiSmzoQmhAoGB30e4JB7eMd+I201y1BaJv8RFyxtmaHXCoORHwafPsLu1HqWOzz8QNUm3MwSvgUsQF2CS+MWUAzEeBo3pyO73WheU0y95P1t5qOO5GA4oPe5PJHzeep0pUlcKJJOilipy0Xul6m/dP1GLU7Mvq4E8fhZ0r9b5IbI0O90Q78tDOSw3V1+Q/d7xAQYo9jPO24D2hHclcUxMd2bHBwnc7Shy2b9k7edVDw2pvpnyfQ327edfZOqQ1SD5alsZKkg+wMeWY0YYhehOZRRcgsbBID2hN/ks1BQsGAb+B7vzfhG+Qlr0tO9tgtE5hN0R0pzwdgypK8eTHOTnn7OWXDurTyO/LhAqDwivGKgPhQ2/DT4E9Skn8cFzcdSosMTxq/Ft15cft1waizG/RvVRuWqh3X/ZzwEymGk0XdkJVlgE6h0yOgGpUsPpQSKmgQwyYrH2dlDKS0CuXN6kFvJCNIPqTC52GoXBYa8hi7a4jwDS/R0swMMbEDb0mUoPSuRi8O3cCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1205!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033344455795"
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


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-231016033344455795"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
