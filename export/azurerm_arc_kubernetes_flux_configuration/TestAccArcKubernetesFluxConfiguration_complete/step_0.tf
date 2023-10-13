
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042923042124"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042923042124"
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
  name                = "acctestpip-231013042923042124"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042923042124"
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
  name                            = "acctestVM-231013042923042124"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6735!"
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
  name                         = "acctest-akcc-231013042923042124"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwGvBdJfm0CfpkHyt3q96iIc6io1QTBzm6a5SEvTGPIboM6f+XfM6RrLEgr0tqfkygeEJg/v/4ub35x4YdGKubce7It2PCsW0a6jDiFsiDfXU4bdnnRCHQkaiagB0N6oa6uCsIrAX17Xe90mz+3vRUF1vls6lxfrw2bhB68LAoLxiRVVh6NWthNwAKfmMNrUvn6LADYkziow2/59thA1yEuPtdO1h8VTiNopptxaMoYyHwZ/DJnyvJD/oazoE6obQLoFi8AJItv+Ef7KuOkgFqlwZDyk6g0T1jZjd9k5BhPIU0rcp/1jK4nxb47xsQrikHnz8kQ1AurBCvBfGvXDVXUu2G+WE8FPNh3Qv7t4HLYeKb3sUz2kq3rHRh2aqijeCe6TDdHPLRkTAInwhXGeVjOUwypYXhwwNvtgIkE//nCrzH5S4F2OCPrzFojs9c3lsnXNfew19TXlJKoykD9gtuZFUSPP8UQRngFaX6720Wlf0s4kNPbRLHpMYJR+GXUYOktzOlhkD9f8/HiwNrWXeTnqpBJ5CKTPI9LK5vbCReNsOy86nMmyt2giSLq/P64Ok65QUyVf+1k7Nx/LGj4gddiUnaMQNnyvhZZ3QGk/vYRp2/3HTOaEbOyV0C3xr28uF/F9o5eh6+fXVr6/4+lwz+fUz5IlXvh8WY/vtliDyrsECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6735!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042923042124"
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
  name           = "acctest-kce-231013042923042124"
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
  name       = "acctest-fc-231013042923042124"
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
