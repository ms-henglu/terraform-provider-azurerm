
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024454317087"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024454317087"
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
  name                = "acctestpip-240119024454317087"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024454317087"
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
  name                            = "acctestVM-240119024454317087"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5906!"
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
  name                         = "acctest-akcc-240119024454317087"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtcy6sTYWiRjt6yWaLRjAff3YCYIcufZvDtrhQIwBVMTWyZYeZzmZAPhkgNGYsoJ24JUDhh+JHeMCA1xpCSHWAixF+2vJ+DuLiYha2SPU+JZXKxCKAvCz37tlmR0DN0zv8JjO33unD3JN7/Sar+oRSvWgxUo1OEnoXLV5lqmPAsCmvUjnSIJ5GlS3dJqS5nDaiyn/CQ+x9nbZw2wt7z9uI6VnvecI3n6xSPUoz98CUSz3JLXNcXtvVnk0oqBz51oNqjjSGaLWEayWxUwFLzSVPePtfYLiY0NoJBySM9wLe3HwBqs6zFLF12XOAjnA004LD31xZpvZtt1RD2l/vk7sOAm2csilHyJzC24W/5WlkjOaJrO5qPPLt5G5OSeVG3uoJ1GrlRGvhK8/9CYhZdQp2YGeREPbbL12lhp8YGxuJm50j0eoksr6DKZseYwxq2smec4dbbFYe8NPcZ0ickUUnrh4DrVW7mw5yvCf2hRBW1zK8Muj3/zjZVAxWDlRnQgl5ezJly6SSvkbWwo613aN+Sl/xVPUUGd1V6Rv4UL7ryf16rQU9k/EKduoS4T9PMjVPv7C6sV450J7ojfIxP4R8qARpkG3eTrbpA5swW+ZxMrIHJ0qkPelMp/dmgfFcp5D/6GLbKRAK5yuYHUyOKm9JZ88ZME4qMkzDXohCtq9ggcCAwEAAQ=="

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
  password = "P@$$w0rd5906!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024454317087"
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
