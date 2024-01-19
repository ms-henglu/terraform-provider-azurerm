
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021547645201"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021547645201"
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
  name                = "acctestpip-240119021547645201"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021547645201"
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
  name                            = "acctestVM-240119021547645201"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4365!"
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
  name                         = "acctest-akcc-240119021547645201"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxu7HwzbXBnN/O6B/GOPNheB5ogYusjEhmlQry/dRvZ5wRwnvuLQtFilK7DZr5ez0seeKl+X/B4yDTWs7pQLdI/iJqUuzHXfspkW5BwpUlhKWfguCoJACrb5WcBPCM2gQafq8eCsvxJqguN9Ok5zrwl1F5CTNG0j1BUTCPmOIN/clQ8XATGvkV4Q0OgAjIIpsIZ++uqutgn5p5Rzz8gxW7x3pqkTwmTFZ8338ICmM4WdGlD6i9ogNR9GBjJPArPjIqTyqcOH1FMPf88llSYVny9GM5/dBb/rQUUG3lNWu2RsEIX8qeaDSh4ijuCF/aE6alOPPhnqN+sWSScCj6bZ6ldQLOa1SrZL/8GMO5xPQWyOc8bbcYiHQr0r4Co4xTRf7zC7nmlnNcYki1gk0YLYvxmPUQIBmxd9VeS1nwfRprY7U2RGPWtL+9UXkrGh1P+biukgH7sIanJ6nEODH9mmUlNzbRHvAwo1orzMZPnsDNid8zZ+779L9vW0wkvtCUUulgHLbn3+nwP+II5XCCI5gh3nAS3RhaLlIAvms6DhuP9D36OigRZsHVTYTGFYbS3s6ci3PJA9T+ldrsT8WRJ+1zoqqXMNou33IZulwTf/MH0rEnn4HlFoXcw1chDR78H6I/dNh5UBF+8iI4V6yqylvKcE2rk5o+HluHuVlcvqeLMECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4365!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021547645201"
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
  name           = "acctest-kce-240119021547645201"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa240119021547645201"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240119021547645201"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test_queue" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_role_assignment" "test_blob" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240119021547645201"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    service_principal {
      client_id     = "ARM_CLIENT_ID"
      tenant_id     = "ARM_TENANT_ID"
      client_secret = "ARM_CLIENT_SECRET"
    }
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test,
    azurerm_role_assignment.test_queue,
    azurerm_role_assignment.test_blob
  ]
}
