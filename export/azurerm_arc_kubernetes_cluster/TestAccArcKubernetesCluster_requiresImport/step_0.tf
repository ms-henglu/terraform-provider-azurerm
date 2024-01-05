
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060237171363"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060237171363"
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
  name                = "acctestpip-240105060237171363"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060237171363"
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
  name                            = "acctestVM-240105060237171363"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2497!"
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
  name                         = "acctest-akcc-240105060237171363"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0CdyiiDCfkaNH8a9MoUr9VhOi6FB0cTeSQS8ohwgrkWGVpSG/JMSaMuz+aWa0snmIIsnwPDSrrz+rk5f9UiZ1eAm6puYv8i7DfunEmcGTILw4GqyZbMhzbVL1RP/kTOqge+wFGiAZUyWnylArmYCQudijZp/FUuRX19KiOTvBKCYGwDFQtItXrZMc58LRUhMwNY1td26IxhzE4DhH4gNjVWi12/VenROOmIrOEXhM93XSzGmPJX6pcBGLH5dT3n8AWQ9g09NQRZWwZvChQLDPO/99U5MBS62T6hG5Yx5hCG5GAFQkxJdviHQN6SnblLBbMiRSTdhORY+paEI2YAIDBfmTJ7SPfe1yB3gEfNTN9PmWP2q9bttYiUa1ugZfGp5UzhbFjBltiTUX77JCKL4pVz2zCtZNSb6bS5EicVF78IWIDMubOsFslJ1/HFgBcik6N5tbWoezb/blBs3j5lzFlTiH3MAlveM+NvRMbSLPx9Xv5AuaHA9KZWtwcwOY8f3zn5BVlnEns/MOl6kRzU33rLu98JOP/cIFAegsdTxKEWIrBSVMlRQqKgQmMrnsZec7SfiXCOMQRg5UDVSZKa2vJTY1/Wko646OaEuUFb9B7JegACKaOFWwSKASYnXFkNoxYiELTHmFziISyPh3qC1i5OKyzvRn6VgszmAqVqkr7ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2497!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060237171363"
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
