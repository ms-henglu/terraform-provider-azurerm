
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031402085293"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031402085293"
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
  name                = "acctestpip-240311031402085293"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031402085293"
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
  name                            = "acctestVM-240311031402085293"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4044!"
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
  name                         = "acctest-akcc-240311031402085293"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAw9xYRbubNyjj2HBHzehqF7Q0w67OtUVUXLNyG4DULAEUeae3Ekbj/jVSvkejDjVMFWgykpr/pWi74JHB7jxEqxggf1pK074gi3lNz4wuQUrAP46T5J5rCuacGEXtNAZ0D/C0X+glVTZh3s5pqC0x1cMc+mVqX6PGHvdfAwhtW7y3XmRj5qUIgGQUZ1P5tYcKohyJkSgJUWiEU7YGJKmYurNjfLdAOc+A+KFOaaoSjva9d/RpL/jAdFISl5KHL2CdpSX5gcic0Ha2JBSdF3pChZNFgZFoCFZBV3vVOYVD2lcIcDCQsWeN0l2Hx8gWiSRqp/ZD6VoNWNw8MyFvz434Kq2v1Z+ZDegR6g8qwBovoobiNwKcnne6lF+d1qd6hVaIGpTUkqFnFCeaI0HJ0Yh4SGDorEfO+uov/h5lr8oyCdtdh4JjL99Xd7GlHIBtgdqFgkwwdfbHjDl6WoWMyJ49wc9e9Y/WMYV67C7e1sykNeTtVTL8H0syGwRFWu3rl/LN5TXIJtwZIYQ5/e4x2/AlkXpZ/X6F3ZTBBlo7WgnwCMcM5cXImaQ0G/hHThvC7Ojs96AvWlzkU18cCpf4yGhivKXyDzf/cHixtmEM5Jc69rMEsUv+9LydZpQVMXFEm8jmiPEQJHzVCaF6XN75IeBbZTN2bOx19ug1bbsgeUrdubcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4044!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031402085293"
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
  name           = "acctest-kce-240311031402085293"
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
  name       = "acctest-fc-240311031402085293"
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
