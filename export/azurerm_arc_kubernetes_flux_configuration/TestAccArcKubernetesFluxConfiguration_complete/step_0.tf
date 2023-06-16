
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074305961158"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074305961158"
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
  name                = "acctestpip-230616074305961158"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074305961158"
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
  name                            = "acctestVM-230616074305961158"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9905!"
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
  name                         = "acctest-akcc-230616074305961158"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwkm6sCxUS43WNSaHvk5tJY47E8VzjSlCqG+5ElwQf/ad1QXj19RIRoKb+Le10wmuWoQJOV+AZkBnjM/nmD5wX3ZOQrWKM/1hgR/1SnOomUvqUbE8hfD49FqrSWtWGylhKkZWS/eUFkrjT11mLKgaBqD97fwM/0Q9bVeSrIhWGW22XKRDJ/GMTp3c9vTSds5OosVVR0CFOpjk0GGP/KvrQgZ4XZ962pxkAKatJ/fQ1tCW5qGIHHO4Ug6EFzlOTvDnTJhPaC2cJN39UQRmeG+iC3RrautfGPOkytTvOnInwYV89nsT3VsKD5SIsre7LsU371fK0p233Wdzs6aYeTsaFAWkro/0vETkIlBhmMbhRAfwhP1lBE0BLlcWzOdhOVyGIYOVAHS0tCML6rsilSJwOWE4LRas0PSCgJwKD4NgTT+Tuf9Y3B+4n62icAW1deBOhFkhZmw2UD/EsIPOturph6INJZ8clCcfPm75HhcGkUCTiVO34XLoc1nDYj1umkTwVyS6mAOvXDocfKNA3xltq/jIVxzDCOOEHdum9fXtZ/xvxkGI4TRE3Jf+CKOxXeAv3fKr+mBoN2vNDWDsOXwBUWEiogKYVQrc3um1nIK9P2WU57qAZi6JA3spExHJAkH3cFwQ7/dmPwguINoHtomKE+gvw/Q+ACjD8k/6z/7OD0sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9905!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074305961158"
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
  name           = "acctest-kce-230616074305961158"
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
  name       = "acctest-fc-230616074305961158"
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
