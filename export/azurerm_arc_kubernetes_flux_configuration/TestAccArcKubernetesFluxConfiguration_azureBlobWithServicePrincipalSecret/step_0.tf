
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023541100196"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023541100196"
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
  name                = "acctestpip-230818023541100196"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023541100196"
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
  name                            = "acctestVM-230818023541100196"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7032!"
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
  name                         = "acctest-akcc-230818023541100196"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwRdosh1uc4wwAQ73v9bdwka98hYUA5tvlFmOGBHhBxKzI41obBSHxTI2IkiB93rLOAV/Se4+R+Waq+WkEJAOCHRslIy8PvycAQaGwFRsRHHqrSaN5aTr4mlJsqnoEKeuAxxVS4UVJvvjKgNO1qGIJZWt0CKZwl52ngWZLzJ6I4HgW9BhEiFQIxqEckBCsOPE9yApBjmedBNqrLpHzOqaJt4lXMVGsv0l5DURot1Y7NCcfhnH65ksX/ElPl2DRi2O182XtKjI85K2N4rP1oU554rkpSxDB6Y1Lg9THV5xahuS8vaA5t3Ydcww/wwelRC6I8LAQXlVizq5AYps/q/zcPcSINNQsLXtBH4ElcURZCf6kBm+VCJQnSU/AH0mHKXjbe/GFRFgtqduK4a5za8CpappquqQTVbgkNv+P8Rspm1S2xI67jkB93PV8HkoEPWR9j1P1jQlF5Ea6EvkMZGpG9KuS4VSbUxj2wP1/r/sr3ub0lhYs7H0YeDzpe57VeRaOiMZEQihOj+dgx9p7ntKyUSZxXOV/wLmlAsg71ZJc4reAye6s1L8aerJPhx69nUEwYsAlEDhwFAjG+hprboWdvEPZbjcfIM1w5KieUt9kZ+pFGRWOIX7ZCv8lXZhg8qAfbO6EyHpiZq+gA36iJeaR0eOUSmw+n5Y/SiBpKWfrikCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7032!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023541100196"
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
  name           = "acctest-kce-230818023541100196"
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
  name                     = "sa230818023541100196"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230818023541100196"
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
  name       = "acctest-fc-230818023541100196"
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
