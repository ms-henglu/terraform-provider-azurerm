
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021526830516"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021526830516"
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
  name                = "acctestpip-240119021526830516"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021526830516"
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
  name                            = "acctestVM-240119021526830516"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9021!"
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
  name                         = "acctest-akcc-240119021526830516"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1mvIfJuQqaTIyD8E15FUp6V3Gvfly8fY3tbHINY0ZLJbEQSPpBR70ZBF+52R+MwoWC5CEjQU+mUEkgCR8AFAzaeg1eB4rSOkMMmqm1uv2x8nU5AzG+1wkFHYv2AR/GrTi6m68WMcVR2FTUHW7+m6jgCJIp02mox3rbBPEtRRU/Uli4oTwrZ1cZKpNZKxupYfp9qclfEjuy4NECCNhwi5BqSzNquScczeuZWVlhgchwjeKUawsASrUyRJyATdAehUuZ3dBG47B/1QfO6uhGRWr7HOs8SjUPp/Wj+4q+o6ahNNmdxOWqK1jY1Gw20CLPPkZLbodivLWXmXUKEsJI/7wpSWeDiO0oZts1mFNX0hYGe4h+M8SUBNmePxKKqv+6HmXkgQxFxbRO1T25N/HjeRa33gokyvS27QXZaLvcw4+0CdLhsYLCBFB8/6TGmUBjErKQSnno4wYzKGpCeQpT4wC8s/w4s6cpRFQGy73fzXoOY01udLrx5Z0sXhHEVApviWXsaEWWZgpU92Uskgf9PgKX+AtdWUP6+VwxIj6Qx734FIqw05DyNzoI8SF/EPe1hAVZsi5H7Q5LdY7PV1zsYXNl8IUzhicHYUCw6hh7yInuany13AU4CiWaVMuh1CGC+PN7O25JoROXp971WW3ZrD1abDmz629faafVeok4O6fn0CAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9021!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021526830516"
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
