
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025100661873"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025100661873"
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
  name                = "acctestpip-230728025100661873"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025100661873"
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
  name                            = "acctestVM-230728025100661873"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5910!"
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
  name                         = "acctest-akcc-230728025100661873"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2H7UL8EFVaHBVTXu50A5tvpWY5GJHytGaU9y0ldaIb+4+axOl73i1eYni7v8SsW0m2o1gULK1Aw65dXp13zaVRlKrMcLMzXdIvwf+O3K7FXghmDjLqzAOtC3sHkhpbyFrXhTC19yfEBQUdYa7Al5hWshURMIV4YkDdfHXiqdxzhi9dc8871EIZ4m9LqYIqfDqF1dPrFMqj9TEX8ktBV+1b4mqcZxtpFTgKL0xGSCyuMiNTRQRuAzSQZg+7AMu0uNdfKZAyJ4GIZVf+lHiVAbROwCVM9AwVcgp5o+wyxRST6DxIwWJgHs0N0maQq0ESEWn7FZvST2EAS10Wdf48qlFGSYhncT1RVhCBUyMFKKT9ZK7MZgalxk8cNk39iu5/LE/29u07hCX2s6Plb/D5WxYBVsk6jucd4YUMq8OU1xCemx/bOgc17fF8qSJB1z2wDc7NFEWc0pFPDkRuqge26twlVWDIMClDnMHFPDA8b3AW52bPktf2IvI98gaTwN9r3BZbwOQhbU5eSJEhHRr1uR01nEJIaAJuGDNEnKP+N5489nP/cDXvMD+eBXI601Sbxz2JYoccLDohuHPAhoNIIVp3khDcwYsSuvVE4yuXm/c8AUgaPkO+dbRBJjjtSjeCicXEz2ARrznhf7gDDitQ/yaXSarTzdPrGEkvOdR1ybFu8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5910!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025100661873"
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
  name           = "acctest-kce-230728025100661873"
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
  name       = "acctest-fc-230728025100661873"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  bucket {
    access_key               = "example"
    secret_key_base64        = base64encode("example")
    bucket_name              = "flux"
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    url                      = "https://fluxminiotest.az.minio.io"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
