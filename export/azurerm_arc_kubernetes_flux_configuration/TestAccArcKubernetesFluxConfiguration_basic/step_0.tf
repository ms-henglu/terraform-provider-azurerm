
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223937765014"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223937765014"
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
  name                = "acctestpip-240112223937765014"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223937765014"
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
  name                            = "acctestVM-240112223937765014"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd536!"
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
  name                         = "acctest-akcc-240112223937765014"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqPtEOJOAwkuNWIoqtrSHEC6NUHN50ZOzp99oXcS5VIE08ySsdMrnf95vAmb/VEgHAEoZaep3K901oMtzDC0joXSPaU8hIsOVzTxvvBDGhef/+4wAUnhkP4sdVV00WFDfIOcNwGCUHliCATZX900vbm9JNE/WquMLRIk3xe4PweLdkIzEW5VVUv2bitESg/ORRpNpXURtxXt6QhfAasDRqJBl8L0Vt5MSdNKJfp79BlF5KpPEZYtom8yrwA6462W3c/KLr072sFp3Zz7LxNdGYmhleFoHs0cVfy8zpDCtdIUV1mWU+c2bf8yMFX0d7zxO/4JjTSNv4qZpm+KtZg2B/i7JjTRciExUAAeZkYRgFX9MleHcp0l2I/fT5KJQjFyPK4QNx2/bT6eYKprM9yP0VwGgOj6Rwh/5S8U+LRLQU3PSBQE219gwis6hcqrHKfEve7KzSFqzVOrNvgqz2044HApU6+mDVcrRWRGZfnw0kYiDWnvTgRBYlgurilDSviDXKcohH5Y1P6eIZo7iiM0GKeDIY8GqSUeqc5IhsY8F5E99mNBziqYdVjOvC+LeJ/soM9aDVSIz/JiN2ijPquXZz+5lL7pIo1sTqwxxWOVHxfU66mm0LoghyV/cwZtyu/RPSNIN9bfpqVkmNtHipPLkx+g45/91wzulO0DU8e30eHMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd536!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223937765014"
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
  name           = "acctest-kce-240112223937765014"
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
  name       = "acctest-fc-240112223937765014"
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
