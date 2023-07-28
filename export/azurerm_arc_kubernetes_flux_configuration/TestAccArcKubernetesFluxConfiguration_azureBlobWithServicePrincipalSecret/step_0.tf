
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031813941262"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031813941262"
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
  name                = "acctestpip-230728031813941262"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031813941262"
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
  name                            = "acctestVM-230728031813941262"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6028!"
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
  name                         = "acctest-akcc-230728031813941262"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2vdPIdxnRYpYv4xA/yvix/3TdWn1z4dJNhaUkNivmOgRC0v6mP+E8EeQOFOLP//Z7WUMJZfJuyLyRqtxHZpB+dlbTPUS042qa3Y05PS+5NuIq3Ds7e6Hf0DME8s1pYTQwID8gPxlrk8rRgh9LoftkMgu8yNc7sbbuaIzQRBJS6OF2IZDZ3F2kYol23ZOGNwNXPIapdQhIy3M8k7VYXtxwaej1547WfPsZq+a+wM+ZSHxhknvaKbznIKvqvfnEK4OaIzbxzvZqMFKaDQ3XmmCBm43ktmMcjZyppWKWE/8DNo0592fxuhlRpYlg9isV1IdtVka/3uDtPMTvAIpWnLx50MYKKFd0JJR0uDgr/BZY/mYj2aApqK4oIjymHTf57EsChM2OpG8bNYY7x1yCJHG48zTvfRDqEmUiepDeokVyry1TlrB+DWltlVYmSroUMpAVEJszqE0N9Kg6oXmIhAT8Kmm4A7TVedH8JZRSddR0ZHYluAl0KIMy1xmX6D7bFjUB4HLRJi7y75zs8hqd6l5UXLkrUr40uQIypLt8Di+bNlj6dC/hEZwYIWBisjvFdBRMjamWP21BkUToV9Dd+V/J+WaNcj1Qu2czUYEwPnEpUbrrz5Q2xHbmotNKf//v6sy8HK2JX9VyXkTDIsYgb5BIBwRhoT2G5gEsBOpM8GON2sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6028!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031813941262"
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
  name           = "acctest-kce-230728031813941262"
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
  name                     = "sa230728031813941262"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230728031813941262"
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
  name       = "acctest-fc-230728031813941262"
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
