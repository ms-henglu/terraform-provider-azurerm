
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025447045406"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025447045406"
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
  name                = "acctestpip-230804025447045406"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025447045406"
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
  name                            = "acctestVM-230804025447045406"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd636!"
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
  name                         = "acctest-akcc-230804025447045406"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApEwq9q+NcCK5gu4RgLsSKs77lEhTdR6FluWgT1LGAZTGsvWqhca7IgQvgXz6bdooGC9qOsz7e9XyzeMTq6kVSAQEacmLPRHTZpzcPXzM7o1BV1B2od8qbF6gSmavqKcoSujM/pCMz4hIizi6ukKDZRIg7dVMcqgp2rVqws3rGsyloy3G4pmFd4T0BHbcN91ntlrXGXz6AxrhQdP4LyR2Epa/YYeEZgNP9dwevKLUSN0IvXlI35mWbFc5+kzzDhG2VEAE5ASLXTmeHpKcR3kPYZjB62hBGYkrZFobF/bUx41zuWmbQDKEgxt04kV4h5jR2cssIWAXPsZrVlwZojTGEh8oFSTGlj4NZLG6F6X4vZhZ+GTpmB9KH5QH9akkTP10JmV3DsvvzEaOTfeNwZ6z3S/KzG6V6Pd7p9u+wdCIl4UxvW+eK3HkLKlKJyT+FsFBefdlOhkMEb6RhLymWH0IwneqioyZsI5BvyN1PPBGm8TOZJQx80wyzkX0p8eNyn1JZk1OjpzB3UDHF+zPrSri5kSg199kQnekdLMX1/WKXz/61DAAVtLlhWu9Ps92aqCpHYGwTq9ku8aO4T/oHC6lXbHDX0ekGrDSU/1QDq8ecO8pPEVvdrqrB+kFfVOcEToEm5DwctNL+khh2ppTWJSsrmGOqyU89ejlwYsPkHaFj0kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd636!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025447045406"
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
  name           = "acctest-kce-230804025447045406"
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
  name       = "acctest-fc-230804025447045406"
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
