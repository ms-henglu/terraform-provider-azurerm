
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074307452485"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074307452485"
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
  name                = "acctestpip-230616074307452485"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074307452485"
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
  name                            = "acctestVM-230616074307452485"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7060!"
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
  name                         = "acctest-akcc-230616074307452485"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1TuXigOto7r2vR4ydtl0i9nIxMWaCmKMEYj81ta+nVl97LwRm5FIqN5gzGtc0o4Dsy6wiOLI0sgTfjGWxpLdN2ncThipVxZZ0qkiT9O5ixzmXNhdNeyCQVOl7WcJYNNIbQ6Kp5sByWmRQ4ZnE+oroHSBQmln0/pV/vEr5uPCEaqQhu9r0PB3A+y5J+S+IRijS5uc3RAASbOeb4ucFX6bj7YtUcLhmZeFTqvtKn/N6IxxMjhTpnyBKc6QEeCIKoJ57QCja2Gg7ufitW57NUyLd+r3NdRlS8ZHMCZXjedJ0dyqzX6MTxoS/QPZIZF27vI4xuTjuBUD2+IRlMpDWsF1xbHZ+46Nbs5n69kAh9e3LyYjbq2wy/su7PRVRHxTTQVaSU8racw1x21np6NcMkftw0Y7J7ySvRCFFetYtR2qyBbVEhYgV8EpxcnmCeSdDibyG6b/Djje7jPfImHSVSzn3ccU+v5gPhHEZgxNynxsx/eOkqXqQ9eTMACwSYlx6VBbyZbqw1vxVgkeohUNKw2U92Nq4VfbV8DZo1nli/0hA7qY6kgqLfbHJFQWyt1iYefKeD4pPpJIer6hUm0vYH3sJHzM2AuFMHLoFjWK1MS5+Bkx5XHXcNR/2NU/0sxxdBan1b6bKwI0ZDBGwSsK/pQXjEyPL4GIj1cmSEIh9ox/MN8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7060!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074307452485"
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
  name           = "acctest-kce-230616074307452485"
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
  name       = "acctest-fc-230616074307452485"
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
