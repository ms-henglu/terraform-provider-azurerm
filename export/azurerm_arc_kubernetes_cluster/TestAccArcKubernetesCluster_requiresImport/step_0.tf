
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526084611350723"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230526084611350723"
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
  name                = "acctestpip-230526084611350723"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230526084611350723"
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
  name                            = "acctestVM-230526084611350723"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7579!"
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
  name                         = "acctest-akcc-230526084611350723"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAu5xHJRxd9zbRswOCi9EuZAshmDwqwbS6AYV7CGHqV0uMkZfGDLB98iltFjiBwLJvJQJaRsCrAHeDQauURlDJz3OTfSHzNCg1WeWcR7dRi4hodYF40ZPXSLwH1FiyrvBraw9kIimxPHtwM+5MD78kGeFEFYzkpX0PRLZKSLJxOCoCG/IrF+Sf3zpkBG7IvyexL2TOcYVna827zsJ33EsQ7FpSy9pvzJA32fGI+BIhRlrtukovVCyewF1JzFhjhgtN7TpccKETrS6zZyYfu+3uaBQ6m1yhDQ4vBYCVj+Hivhqati+pZAo4Yms++TpUEsGPCWsaz+P57/+ONpnb+bZ9zXJYTdnll/b+uMb8nGuNWZamFAvfyTi8kz/tNJbZ8kgxe4DYY+Rz4LluyJa83TOSGs3NSFdGL6IMbMOtYmY7WDjgaHaHaakETuiOJmryqErDp/8DbtxQWPGGmlDpNZqIwJhFR/QNpB25b0rcPhvdG06QszzO7tMayIMkf4SokWsdG7VqB45oaMYUSgv/YTUrOd32UqXg9QeifzKdykxTXEIKC22H9HA/Vbma7iAqHUwk0hDpaR5hyaZOMD8qenVSqPHV9cPrXt+kn9xWFLdiwS5zibBggrEJWvwETJu+QEkZABvtinuHZF9tlLlVRGAR7m5/O1qQNjZvqA7IVoduEBUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7579!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230526084611350723"
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
