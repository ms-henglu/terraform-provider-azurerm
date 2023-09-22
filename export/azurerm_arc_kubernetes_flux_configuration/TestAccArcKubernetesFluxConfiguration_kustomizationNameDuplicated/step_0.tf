
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060619672623"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060619672623"
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
  name                = "acctestpip-230922060619672623"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060619672623"
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
  name                            = "acctestVM-230922060619672623"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2807!"
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
  name                         = "acctest-akcc-230922060619672623"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsh4R73tVF+tdndpu4EocK+BGPjBVpvWLF3BcKM2K6L7bYgPrPVsaXxYaAUUrPuAX30pWF7pVmC5mQ7s8t/ppc0IWxcfjahd5SLdHoNeplaL9YrEgN0EhaiqfEEo1jYRfKokCIXE6qcYxApLjL4IRJQF6SXmohdpMKKZTpXzkcenGz8DoKNQ51i1PpfhXs066RN2pLS8GYaUJbmWQEKkAIRTg6SkzF4mNCto+Mmhcm1D8Bb0zmsALvjwIMSeu/46/oXHtwfXl+p3OKt3LvXmlPYIAFxDJmVI2nZeJfg2wp9OSuvZWs8lov0gxWQgq8BIJcfUhuq/Eaa1oWxwwqak+kcnTTrOlwdE/nsCX4CykxrAY7PsdohVLB9FBwBEj/BcmIPvdpiYPNv7iSAlM4ZJcvcCpSSwKYxG7J8xrbS4V1ke5LzpRAZZRq9Vwo7HVOSB8egaDo2fC+CwOPJLlaMOsXFbgT85yscxH8EstKPbH9KCtIkaGELtAcMNKHJjU+1NYbm5WKBEPaVC585EQxJ5tyXcwHhUCqrIMH6k66qp25KozRVL9Nlu2FaHRq1ovWF+Cn9i5r/gZaAoB/O89JEMzGA2esse18DLpJim35Xyhg36mB3yQ4NPno1aFjSGBLjQM83fLdpNZhOOqDdKaAHwjJtnmTAmNctoOiZyJ/irLR4kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2807!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060619672623"
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
  name           = "acctest-kce-230922060619672623"
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
  name       = "acctest-fc-230922060619672623"
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
