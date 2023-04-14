
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414020740443549"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230414020740443549"
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
  name                = "acctestpip-230414020740443549"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230414020740443549"
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
  name                            = "acctestVM-230414020740443549"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4428!"
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
  name                         = "acctest-akcc-230414020740443549"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvAfyTrhkAp21QDKnVTAzj4GhpLQxsuxVRJuMS2yxWy79vvd1nfZn+ke0rUpSOkof7QcC4XnpSdNIb0Atw9sWF5UdLvYAOtATGjNO4N+u56GeIPnqwi0/BduX6sp/hyJwsC3/uX+Lo1hxRl1mKE+Dm3tgabeG02Fr7tqrRNHTIHTVQ4E50MdJ0JxGP2S0aokJA352LcOpiHo2sXcfXvsfH3Ua366rleBk0RA1bmu1n8gjBmTmBzLiFcETqQmDE5mJe5htUnC8lbAX/g7PEjwgPIcJGwoLHxv6yiZRP8Ymt12g6wvNBUUdh9Vy9uq7Gl4eY4cLWtNXgOjH04uOXZeVL6lYaud0Ec150OjZuB0hkpessHtcaL+HnJoMNdaFiJmVzYqxDpoNR83TtwI14bJ6O8W/hw6QnRBwNshuBmw2Rit3neszOcjSBMI6ybLhQ1XdXihyu8zNaC4uHtfN5V6nhFdSsaRXSHM4vZdZMHj3EShJKf/vzEUFFVUBYKw8L4rpTAxxz5tPlagMyUoo29wnQtCurG11EYwZ6zv8Xfa+vI3/iBv+skZmRIl1Ji65IyRpqrS22VevgMvVLlKF+I9f+oBCfCjYyNDKnLijjs4InZNrFj3GnSezDEo8rwmV/hET2wYHG7NN5KXIqQ9n1DpVxDdb7LUWrZn23OYPCSu2nI0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4428!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230414020740443549"
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
