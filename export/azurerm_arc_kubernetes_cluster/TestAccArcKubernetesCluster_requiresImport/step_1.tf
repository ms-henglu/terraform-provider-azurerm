
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421021653688277"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230421021653688277"
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
  name                = "acctestpip-230421021653688277"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230421021653688277"
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
  name                            = "acctestVM-230421021653688277"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd710!"
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
  name                         = "acctest-akcc-230421021653688277"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAo7YNg94k2l5Usapp4nhVTtCy3dqCwsJdkcrV+MkUUz6nloEvWHU/Ou/+bEac2FKRo8PnofJjmdcnktG0RfvkQzONze6HcIA+lTQNyDssoTZoWs9eeRDNIu2BVzOuhpQJNVHTO2+OooYH8ChuyzPDWuwPMvhtucYXykkzMapglvjLGGuYrKkIQRe0yCKRNvTxuul4XlWpd6AKHqbo/D8uV+zfUak78RZrByzcJTaYal6T7gLQ4tIKUlVwAZnYSDHNqNYkKi8/z6Bz0Hvj1Gfbs8zGNE42fELTR6NEPRCRq6BuAa5Fiy2ILBBg9ogd+YAFb5/Q3Segs90j0/Md98up6QNaAnjIy3mzbfcWlCFPrweYWENf39B7SCaDOynUrBHl5RnPVIKqQoI4SvD3F+wiY/EoC32PmXxAE7wRUe9jm1pkE4op+G4NH41Efk5fQqX4+CnFV7gQpVPk4cG9uaji3eyusHjEqVKbX/sANKd0nTb+iOGn4Oo4EX7N7p2bRi0i/LUKNgaAXMR65EFWzD/8wdu5XC+mXMY5vTmW80Cy2D7yCDQbClLSumxwVY9E1iH/beX5fftD0eczV4gc93QAIw5gOaUYJgrV+wKRa9RBS6RoYPEBkGu2nqLhMjijlzOey7Ue5TzRqeq/xwNVGg7xV7PD+So1HjTDuRcOcXgZcrcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd710!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230421021653688277"
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


resource "azurerm_arc_kubernetes_cluster" "import" {
  name                         = azurerm_arc_kubernetes_cluster.test.name
  resource_group_name          = azurerm_arc_kubernetes_cluster.test.resource_group_name
  location                     = azurerm_arc_kubernetes_cluster.test.location
  agent_public_key_certificate = azurerm_arc_kubernetes_cluster.test.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }
}
