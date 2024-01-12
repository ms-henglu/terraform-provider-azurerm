
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033849076913"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033849076913"
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
  name                = "acctestpip-240112033849076913"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033849076913"
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
  name                            = "acctestVM-240112033849076913"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4809!"
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
  name                         = "acctest-akcc-240112033849076913"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuqRkuWTP6MkuJh1Cni6foPsgqGFwvhCbEQHIA2DhBCTXl7q8mEZrygUqCzgjnfkLi0BSo+dmFoJejLZl+ouCEP4BR6mON7SdsKYQHYqUwK7gRMxGjVZQecydTk6E2G4+X2UPFECgX4kI5eR5t2e8CQpFqe7llbmME5G1+uR0a6lBtL/OVs3nhgEF/ndYJu5IryHEx12tcuPgKlc62KmFuHD6Zfkhpg0GQF4VSa3ur8I17Q6NHEzEcmlWZHK75I7GcpOKl7EpxHNR7j3U8e3mexTnYCCvoe4XUh9umELqFhLgXwpQi7AdZ7dlxfrTZ7e9Tk4wzoIImlQOrLeAu7qCu13GUr7ppZbmHkWS+dun86iACGqqSIdIZhDfrs+HkQoL4V0VXjNZtWYKzzucdySmt8DyiYw2Fs9ohaCp2WNXwhEqCtqmtR4whenGPDt+BZ/3m1XgM14u12/uvlZJ3pnlMQmgFRTJrtMA/dYZ0aFxTTYjRo0hHpKhD4MWBV9H7IO9qMvUg9zNmT63QYkmTyzRFjh1wS629OmxCOc1vGBcq4JKmx3fJPjSzRjTErc9SU67IGhOu973Dk+AflfuWKdQdVEvV25GCTdylM9a1W0fTL7d1JMfUK+LjvHUvFmYkERimkPM3SY0fYIjF68nzQQDt3qA2IoaWR1EMM6TGoDdascCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4809!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033849076913"
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
  name           = "acctest-kce-240112033849076913"
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
  name                     = "sa240112033849076913"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240112033849076913"
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
  name       = "acctest-fc-240112033849076913"
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
