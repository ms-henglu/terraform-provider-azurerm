
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032707033622"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032707033622"
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
  name                = "acctestpip-230630032707033622"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032707033622"
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
  name                            = "acctestVM-230630032707033622"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3760!"
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
  name                         = "acctest-akcc-230630032707033622"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4HQMYkW8pVCmQdPq/l8DHOpRhNc8dNS/0CMMLEJu+uH29LPxsYsEBCThfjWy3E7uSZfiJtCFMjquJzhnmUBWxSlw3PxXha5IychMyJrl9ubGZkmE5LZ6S/dl3q9WG1HcTRbIbdKzAZRCqYnP5VaYcuEar7DtfVygEBSo6a75AywJCanstSp+PZZD426CLZqxF6JY+b0fsMoCH8wSuCj7rmNDAj1wtjZ+jbMB2vzQ2NSLi0Tel/hFRT6NI8hxNK/Grf7WgyZQEY810OiZ7xUZ46Nn3jTA8Ha3Fl7EaSP/2momndRvwkCjZu/cmdQ130FU9bjVbBH2LmL/TbUrl/l+YIY3LReXvQtWlPtGPhuaaGT7ryygdjGnBsPBLf5hVXbxTUZFg5Q8P0bqA2Fze1bm6YBuq1qiJ1lTymand2jCXwo/ocr2H3PbqklzoRKWl+910NklJ6ET7AsaG9cXVIWKcy/SkU0wJzqLq56UrcDMwCJPcz8yz89FomNd+a02847e4tF5SqkDulA8teaqy2fZQSDHdxnhn9IT/jZrXY4g7zSHrVNs/vSt3XqBI/LyXf/3fagKtSRy3FecYy0JqphCNkP/KvdNch2WDiLp8d62wFYAshMbcHVln3jtWVaj9LyxDc/nZ4yiNi8pXiZk/IAocxv44wuxV2f4XYmkWapePIECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3760!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032707033622"
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
  name           = "acctest-kce-230630032707033622"
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
  name                     = "sa230630032707033622"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230630032707033622"
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
  name       = "acctest-fc-230630032707033622"
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
