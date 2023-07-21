
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014511014732"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014511014732"
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
  name                = "acctestpip-230721014511014732"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014511014732"
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
  name                            = "acctestVM-230721014511014732"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9776!"
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
  name                         = "acctest-akcc-230721014511014732"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAocFThpYYJLTiLx7sh4fNPTh+kXVXlFvTl+FPzGYvf4x6mfsvSIOxFeU4rvD4OZB1Q3AoaFWYlDWMCoI1kjj18ZT6XOgIRspUDSOh+US2ZNw1PGpcoCb3/t5Vr+3Sc7UYiHOrcCHrPE4lkoc2OHVagBRx54tVdG7UIpeduORls2MW3UjjhOfkMHeWGORBxBEfpEANwLsJGn5APbK1tK+8l49Go6bWuHFt6/khwtbKUNtS1QoVWLLo6XQ4IdHzKhsjMg60uTmVGsZdoez9o0qGJGzCP4KVEQ+FWA9dVRyOkAN3X2MSOZRKvPMAeyTVQ4WfAdRBbA+KAMWukib4zxlaFxVXWMAvOolM16bTGl7OSeuSBeXm+QWOH5v/iiL8RixFedifZpZMHRXJVcpIRmzh7A9jRCy+Hwd6HxSAriPujkOozGp4ImB3IntAz4FhqF44Gp+9FDNptgMWYSmNG/ysMbWvmExQnPrAFMbhI+PYlEGq9VBFEFSC9nBRfMMUZNXYOq5WxtreovZ300AIM4+lvbODEcSHuDY+uhXmzutBn2rRK87u0zImIBxs4D4lNJq7cdouDKf+t9tv0h/a6f4HLuVBLV46g8IAHnfngbVKR2ImtIiTB0E2R0PzL7OwHDnIQw3IgmS4eYC30j0nQ8L/VEsAhOM/o2b4iB16Mvd8gk0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9776!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014511014732"
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
  name           = "acctest-kce-230721014511014732"
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
  name       = "acctest-fc-230721014511014732"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
