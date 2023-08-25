
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024052141877"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024052141877"
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
  name                = "acctestpip-230825024052141877"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024052141877"
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
  name                            = "acctestVM-230825024052141877"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3598!"
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
  name                         = "acctest-akcc-230825024052141877"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtJn/hM+/mFZDBMvWlWeWy5JE5Oh3bQSET7y9vISLYSSHY1mufxZlVp00nx04p0TSrsxXSHse6CZLV/OUhrGhm5wK3R4TN7vZZR9/aBJl2FeMnd5pkvzfmUT/h/1MhZZ5+UxxvDObkGKNwdXJQqDvmnL/ucj/78Yw7yqpeQGjdyxeN06MSTOUdbu2e/axwnRGRG7E84c5CgnV1y/3u2zKt01v/Olbqd3jRY0K/BnYcu04b1F41ieC79tBcm+XqpX9EVD7laQGc8N6pxfQzwMXog5ewVjiiI5b82PLpe910WfY+Qluunri8JuCjX11o6m/5cepUOhOcOL5/PuW9dVQQZ3dXWqDiKIOdi35nF9aA13heUrGerASYBg9yYM2Dopus0So4on8npAwS68Ad/9GuXIkMkONx7C8KFslriajWrdzMm+f/9wfXKGBiXkz6lAdYAB8pvG6+UAhAZR8P6lTTGnBflU6euxnTALH8HsXySL75AixI98jv1Hqo0ZfY3R/VMYgaGpoLBrhKVKQE6s/9nDMuIMxErr6iC79JkAK1az8D4WLpNqotQ6QCnIWV072wZAVFDYDoM5g0hJ3JvQ13dSVUK2sHIPifdUs/pVW1Ur28WqL0aDuqc+hccKyGPqYaywJs7+SU81DsHb6tF3XWPPMZ45dB9FAH1Gq8Lq3vUECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3598!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024052141877"
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
  name           = "acctest-kce-230825024052141877"
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
  name       = "acctest-fc-230825024052141877"
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

  kustomizations {
    name = "kustomization-1"
    path = "./test/path"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
