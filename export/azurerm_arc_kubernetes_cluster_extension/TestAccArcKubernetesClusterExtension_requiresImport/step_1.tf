
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030132545277"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230602030132545277"
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
  name                = "acctestpip-230602030132545277"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230602030132545277"
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
  name                            = "acctestVM-230602030132545277"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6366!"
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
  name                         = "acctest-akcc-230602030132545277"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0ehuQMHHb6nJ93hmVxHGLWSC5uvK2mvqkGpycUg/Kuz+esSu/YVw8EmQdYpsaq/L1YA9K5cSltSXdVsXMALI2Avle8qmw+7WBjQLGzatOGrQlAUf841tPRem5/GWXrqwwVo3z7C0k1DB16+71LTO/9FXbOysBrEDVj+bJ4n3zqRZED3cBEbbnti9BggrutVqsjpOui3Cko5oH/Tj5vp2ljkPvu0AUO/d7xdERKUDTOrqxx2NgibVZDWySW+ljYcZGkFLHUaHCvAy6kJ1wOhFZidWo2nBlgcoM/ZbIQuBIsbBJZ6DkC/51FhS5yzX1R4Lha7hyw/alTfIGz6imo5N4Val1Ofb+PnUAUt9/pDdfFT3XZERQrG6afNwxM/lrNlTbIfD7Jj0p6env88w1zbfKSq0tEyR+HOH1WymRy0llS33MpQm1Jsn3INiwO6Tgww+46vwxnZFYF8YYd8jBqpkKX34Yc0Er4Lz2+hvyEHmJc9zYac3aLfeNMaz0vgNXMHCs+zNMiwZWUff+32+tRz64Rnt7fpiBDDYdEKYmx4Y6khsVSmpFFuc1b24BsfUPFKSLqLZeP1QMMiM7yqfY1mgVys1lL+mRuHweugrOnx2AgP5WN9BHz3ihUfvxp3f8b7uAcHceeZGWkhzcFzs/yJg9//GYpQ6QX7TYPeaASvUTw8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6366!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230602030132545277"
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
  name           = "acctest-kce-230602030132545277"
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
