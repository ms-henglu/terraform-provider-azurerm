
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005956741283"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707005956741283"
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
  name                = "acctestpip-230707005956741283"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707005956741283"
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
  name                            = "acctestVM-230707005956741283"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7197!"
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
  name                         = "acctest-akcc-230707005956741283"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtyGOHELpTXj0lY09fw2d4962XmksYgI2Dv/0vOnESMmAdQmCy+TIlehE2tYOAMUIn4K/K5uNYLK1NhhtFp4ZIun09RTm71xCjMoxM0RueX2HxEXE19N5VkOvQRrlx4ERAiuApDfLteiCul8mrL2Z4NUR/VgBLEMO6ENZEc++G2YrmpXmkK3VeoW4o3n+CFGuvqC6UuCQnJESxo5ms9ceMpfWvvsFNm5sWnXeODFzI38KNXzxrcsWEjidrIoF58BiM094QazMbaOXHx6SmORFC258bgFHSIBhnksRTAPYk83+5k14r26ebjKNzImpe46lCwQeI/m0vjn1uqsbW9aV30d6BsXSAZId6P3fbqgtDzHM24qvHzw671REV1o/P0Y952qbgBxyRLmvBRZRfZ7rwb3BZBe3/kogQTAPdUm1NxyVJCz69HcTnePA2vgQdCYZhZaa3H8uXocI6i8GHAUf8dPaNykZVS/bky78f5r2AKmg/Hv/4XVk0odtsrS+bPHyqm3IYa188tsGzMDLesJWxwC1EzzjXmid/vqYo+iclUMiJTu44I3D1YeSEQjWCaQIwqy/Mug4bSGeHJZwC9M3Ii9/6IXgal9+uvS/0ekZnchx+cMOcDCOoAv7l/s6VgMjpOTWKtFY7/pjc0ldHT5Gsn78oQKLMina1vx6kY/G1/kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7197!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707005956741283"
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
  name           = "acctest-kce-230707005956741283"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230707005956741283"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
