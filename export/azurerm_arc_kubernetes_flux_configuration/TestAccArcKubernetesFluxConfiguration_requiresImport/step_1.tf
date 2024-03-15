
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122322047444"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122322047444"
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
  name                = "acctestpip-240315122322047444"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122322047444"
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
  name                            = "acctestVM-240315122322047444"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8348!"
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
  name                         = "acctest-akcc-240315122322047444"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqIREZfEFvR4PL38VA5nkyPp7YXlJZx+ijAh29CrwUWbGospJQ2/nNJZh50/l3glbQSa1fMt6W9CUmbnzJK0XDGqNouuYvkS6TtvYv2pzItukig28BCh7XiCj7qEXaK97HuIEPhKVmFggQu3GIoHGyMQELowsdUxuAF2FV4414awmVEVqf7KOoR95OiCM+b/fFoy/IMwMhblDNZ4JXR5DFhK8YcCBUiXLMbWE87IVnLZi92rLJYcCC189mafnyTfrdFKSOfYskP9rsChE4++YU5AXsCfqZeLbpla9ngytpcUXBNocOMvHWiRs9RWdbySkXXjRADazibG6lvyJScg+KZHPRsIN2cliGWZ28pd0029nLhO8i6mrwk0W26O8Gpw+XQ9vJwGFBFytAmshr0qlfmrN6OOcCfPYNqz5Vk/4ek1QycCEzDYUCEEWKz+7zddKoIh595fvf5FigMKyIzRx+S/HgfO6qVoO2enN77Jk6OvlK0ekbNnvYCh/tZSpJUt9kxQg6Vuk49oEuoK636QxDb1kU8CI6XVfnpnTL13mIX51dWYfXMxr2YeUCOQrwG53M+JyXy0ZRUtvHewSS37s8vD93KUADKnUdTkT1uc+i8Xk9jC585h2On6s8sBdxYCLtsybKP7IM6tFfblN4y96huHnOApiNIr+dL+/pK884GcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8348!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122322047444"
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
  name           = "acctest-kce-240315122322047444"
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
  name       = "acctest-fc-240315122322047444"
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


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

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
