
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064340989691"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064340989691"
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
  name                = "acctestpip-230929064340989691"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064340989691"
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
  name                            = "acctestVM-230929064340989691"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9407!"
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
  name                         = "acctest-akcc-230929064340989691"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArJ8pUW3s1ueSxJRBLOaW2Llrb7XGkWskx85nIR0RcQNCGaJ2riWp9duvPRfKCbKsab5kA6x4423P4oAPXu1xvjyYAsltrIl7KifQl0zTL6Rmy8Iu4LQrREd1Oz8OrA3zFpCncaGLG4IFIRuFCMWWJIAFeKJo+KCiFd/Qwn88PB7RisthI2qIDox4LLoVYDFRKMQqozDXe8IiYPgZwDnzsvRrY+goBIxhmtpy1liuMcU0ruTRKOhZb2inZGP/qYUHD32KqAh1LcuzPSfkWlTrc0amHeP8a68cS2hqxQsxNrZaJeiXun+rZ7Y9yoZyjxYCJF3P13XN2M4UZ8OhCarfD5/FGId1h1KUjB3Foy4zU6ViosF5UCCPOZbXvnEJVNA65seOg2l9y9LulhkmvEgQU1+0KTOD+H2dQk1jgfdZwYjtnVjuQGY7ARV2gnOUDm9fNeyjf1WCrZoNVeHSzMm71WiTS2yc9cMIEk0aYTwgfxhMqMpo3FsRY3jt4Rd6wXZZdxv/6IHa7+9yOyOn40EmfAQXf+hrjXVriv9U9qp3bHBgw23g2+X5m/g+/RhveAQ9FgADWDdz71sx5SIZH1y3N0S8lXQ0t0la9fMLrId3rtq6Svcp8kJRpw/2pT1p4+q527QwBn6fMGk2ems2OAN6nFHN30MgoFjEEo1o8F6kBUcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9407!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064340989691"
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
  name           = "acctest-kce-230929064340989691"
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
