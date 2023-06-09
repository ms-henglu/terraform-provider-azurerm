

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609090816777620"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230609090816777620"
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
  name                = "acctestpip-230609090816777620"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230609090816777620"
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
  name                            = "acctestVM-230609090816777620"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd765!"
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
  name                         = "acctest-akcc-230609090816777620"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvBwbljy83nPAWLsS/m+qREwvptW/KpaC+Ttpv8mme2dhdKp+igyIhbtU3elOZVbQiHiZj6UWxBq5w1EK6i2KpLCHH1mK0sWezExN4inoM8c0vfrxKQbxR3Zb3FnhHamjhJtBERTDLePokxBDVyT6xyOxlV7KnfuV1lKVE1WOG6zkTw7DG57WWjzAX0bIqz7ryZIi9tO1MxZZG85bpaJ6B3dF4NEGPU64z8mcYWOKVEMpwuaMCxcndK+eRQ/XHRGsJN/3B7l2uJY/FJjRUx6PrZzTNItXotDamlj5holnmMFbV3Bawg+nY7oKRpVUfi+XWg4PkfIkU8dmvwkiiv/mQF6Uc8lDio7RrAwaP9aRJ7Og3XUkUyLBXrfPCJ5DI5ZWhaAJMp+fQvJ/fYZxfHhn8iGNCebaMCCGK0Bdm+NvPQnwAnymC8hrQ6nxfpzYp51UV4N9HsLbiqnVYtKlVB47pXQ5esx/cPP454qPIA67rw0TwwzD7x8TgYDL1B2ZJIf3RMBXXo6mbNqpgc3o4G6I5KQB5L1AWMtFSaUrrkujB/tykCYb+cKTW7zWtnJPa7feAAKR80YsRDKj9QW8E4fM3E8d1pR9xvtKt4DWPJjrnHM506z5CRNGh1LCL1N7fVD2v2uGUsKgccxWAVToHIo/51bXHFAKAPDvW16W82NjJVMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd765!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230609090816777620"
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
  name           = "acctest-kce-230609090816777620"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
