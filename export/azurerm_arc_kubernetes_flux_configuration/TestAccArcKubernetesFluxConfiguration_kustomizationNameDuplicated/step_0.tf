
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031817842265"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031817842265"
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
  name                = "acctestpip-230728031817842265"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031817842265"
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
  name                            = "acctestVM-230728031817842265"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5709!"
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
  name                         = "acctest-akcc-230728031817842265"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4InHSvHS9jVu2bzOrUiy01yF3oOWqPXz+TjKs9MiRXQwBzMFBb4xp1N0jR+rWwqchc+YoFYy566jzL6koQOa8wvHVvR63/hODEAujNhZIB+a+MsIz6Mt9bNeNSeo40fYhQtjTn/GtBhuLBzf9UbKOhnrwUlM22raIy/U2fHmeNSx9fbagYxO6bWgp80WWduHluJ7WYF2i2tKNuFUB0YNt8n8kWrsr4FA42WlFe1gcyppfuNFrTZloIcxWCWIY6aY4HirMz0FPRxbNDL0+rwajOIOc6GNQdRObbfGNIDwaBZyogfySidvV2PBvTvpTP9nK2LDiFW8r5fn+S8U3CXLpnxAOnuag+/6P+rrIdW2+LFNAkXRIzfPOYwi3slzPpeuQEcE3+iIPDgsDmyhVCkwVLsC/tkWdReNL+MKgNTSZ3UysOud3b+//zPKG8TeIH9fgkjYHqfDueNQVGck6ge4xn8GeJHymzGEv1o4LCJaZvchm3getgpgC/gDpvL2aYmCFjdMm2RE0Ky3W7Fp5+jxIl2cgQ58zb8mekUOnG/mettYKGDPDo+Ka1QOX6yeYqYbyE9OwvfKy0qNL6UYY3R8n7t7hENVIxZm4cYxB7MqeTOqpr4Q7bCaeuV1G2TLOHLotMZPLArbllvZ9EO2w96RMczBGNzUYMUyXbUQRzlti7kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5709!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031817842265"
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
  name           = "acctest-kce-230728031817842265"
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
  name       = "acctest-fc-230728031817842265"
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
