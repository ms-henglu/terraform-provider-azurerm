
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074315894152"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074315894152"
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
  name                = "acctestpip-230616074315894152"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074315894152"
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
  name                            = "acctestVM-230616074315894152"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5644!"
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
  name                         = "acctest-akcc-230616074315894152"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsytbPa8+myudViqbqHWaD5/45jRPeMKyegt1xS/9CW4yVcKbwmIkXdI1FoizJPoepokEY+dw6L8sDpVMidSkRpi+8b3x2jt3lh/cGbbCPRgarxAq9VkdlTya1GeoGiDy3bO23cizxY2WeNpqHVDwRvRvDxexs8+H5ZETAmmiDkwF/nXchmQCCJ9hpd270zPbKG55z+HcgLfV0IS5fKfUVTjr2BoVUA5z8VqRNI7GP7Y7y2sGyt7DZkaj2JN+mhYJ11Li4AwJIsM8xVSUYpc0mErFxscZg+JNjJWTkp9srPYVCoR71EB6xQToFpi4G+5/fMpPxb9V3fqeC/clWiCP9ZVLTwNmXSXdzXESLSCxg4Eunzmazy9waBdkZ1N+mJRUuaVgt0N9nV9ZyTr4VnxWHKdm9rFoQuB3h6Tt4AL2MxA0W44eroJNmI4zsZwLcHpsvPGbdZwoNzMbHhloe93jkm0RsxyhAAO/QuZLVz0s62QuMlB0kCyG4M8Cy6/bTqJexmMIt2SVXxMIJLrRLTTEoIgVmofUMQnhSw8vz6Kr3rx1NQEUuqXdUAcDT5ohfa+Vup7iPiST/TzP3TweXwJd+HTfl6bSgCwDIbUbbtOUMX3CZTEgoiIGAorY073jEFkDP/0HHDfRCqmi3m+oV7S9ik2hmy3QXqJmAsQopLdBDMMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5644!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074315894152"
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
  name           = "acctest-kce-230616074315894152"
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
  name       = "acctest-fc-230616074315894152"
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
