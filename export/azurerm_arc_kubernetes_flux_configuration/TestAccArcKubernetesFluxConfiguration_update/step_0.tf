
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014513445673"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014513445673"
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
  name                = "acctestpip-230721014513445673"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014513445673"
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
  name                            = "acctestVM-230721014513445673"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4998!"
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
  name                         = "acctest-akcc-230721014513445673"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAv8DeA79lMrzVrx55X1XqWdPFDIEuKqZY9bSuL97F7rtIAxZAfHuMEds//7iwxVAB8kHi6/89mLaz+Ab5qZonWgXQae91vSUpfHry4smOjrqQ11UtWzQ5K7Mcwjwk6750bNHOiHFNfNQUIYhCSG06Djf+g9QjZQPVko6GkPaFdCozLLXpWzD9xffDWkNJjynq17h7J5GazEkT/rLupf1aFOJn+WHJRqsEo9PQiDA8wJUNBAfBQGcf3fs1rAnHn3pWOuf12e0fUMj++U+/BMb4KvQ8dT1jE+qHPHWppskWqPV0G5WFeX4FgnG7sU1Wjy/ZmkhIu/PJzGxfZT9uzeEpGI5fR+BdBQ3WdMHHxd3L2dkCrqWShwXIRt9WUYVe/5h2oLq6h1M53vuv1PiyIe5ZDKVc0IOYwBzRp9g8kzMci5hWKpIYNzy9yKsI7rgM98+yqVNneLYXzT8MT+Kz75D8CFInh48zH1jvJ9l2vUWfCrbJRqibRYXNDY/W4v/EeefIkdzqQkStib5Qg+R3zxkthCW4GFMhSuF2vjQhwbmqDKiFOwLHjEUyX1UOS8+NjN5Gl9Y70yuVwZOgJFa2wIeIx9CC9t+NhqEepKBAMR5ge3FGkF9+8rez1MCfezdTqWNBolkuLlqjFGTuVRGjygdkIXFcfvkalWUw9XjFhZpfQTUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4998!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014513445673"
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
  name           = "acctest-kce-230721014513445673"
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
  name       = "acctest-fc-230721014513445673"
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
