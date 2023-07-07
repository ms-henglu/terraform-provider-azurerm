
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003332140133"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003332140133"
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
  name                = "acctestpip-230707003332140133"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003332140133"
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
  name                            = "acctestVM-230707003332140133"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1501!"
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
  name                         = "acctest-akcc-230707003332140133"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAlpeHuGDv1aoydkdhRsc0epnxXuA6VIfIl73bnFMjen8YGSSN3LOZed3KDJaoyoJwUHjghHzvxzeGRr9e9IqGaw7XS/riR0kFEoUh8f6VeeTNwtRbLM3idqqpIFmMEWMuvftGaJpo7WgarbivXMG4GNB6KD4w7aJUngF2XEwkeCOz18hjOhVtuvTLYRt+PwYdElHrx4Wxl6bpvNP3YDgcdab19QZffNruLsWxzsB0hgcjR/pRH/1hsPnB6c5BhgKgzbvln3SRG8xZdh4/JL6opcIn6L/IvmijuiEKPIXbLPgcdZoyLwkwF5gRxKhThRz1spk5fUtNIQwLxF5eeCnyzrtCO5Y6/pyIga8MaME5KXuokbSWKjVtT5pfYGrYaS6TkM5/vW/ZmFf102R3sJxSuPKkkwNaDuYWIl9kDeUOlyN6hHoUAy1DhuzjqPZT3VRFe+T0b1BDi1TX4/ByD8ES1uyvaBky6BMYNy7ez1EkOHSHUFOp9AZkti+DF0ks2RkHQ7MWlmgiftik6QgJwweG8Zp8D2pRa3ZarfWrDnTHXwNfJ50Nghzv0ZQiT9zSfKnEIW50TI3caQzyxHDiPeFjytR0akSNeqSVw3EQJ4xKuSxOassE6+of4fjdhIkJrueTV8KF9vdbtqEWwy8kYphZ1YRACDBQfUx4a5XlPlV2SDcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1501!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003332140133"
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
  name           = "acctest-kce-230707003332140133"
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
  name       = "acctest-fc-230707003332140133"
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
