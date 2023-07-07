
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010007870750"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707010007870750"
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
  name                = "acctestpip-230707010007870750"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707010007870750"
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
  name                            = "acctestVM-230707010007870750"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6264!"
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
  name                         = "acctest-akcc-230707010007870750"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1oNa6KGOTApTB7UagMNiJIbwNx6GZjOP0wxJ+iwtCfmJvz2FEW43ryftzbBkQFduBgcJNOkVtzFMsxgV+4qVvrDBXZMvX1OmgpUKCftyL/9O6Kev40hQH8OMUDj0UaT6j7XGPnD8LTYBS2uacq0HzFAwBKIBQgHXFpPXheSsab/2GwfoMAYZlZIkSggF8/gUUGUzO2Fvj14a38Ng0+v6XvWU4X5LGM3JpuniEgrOm3AGZvELqx2Ho2RcDMu7hITvuFlj9NXQzJAZjpwdTJdQzdxrUbp97h3pHPeLXxuSiHcFSdv2sEXEJxkfWReIoupCCcox09OYcCRtaA6FThM4zMiCWncIR8Awixdnh5gtJhWASJtLaNs6O0ybFUUW+VMK9ntc1CgLD3vDfRJf9JkOVxF2UtOoGiTJQ3/+pHsYTt9DiSMQQ0sGMkSnySKgJ8eVt9GyEbgS/BY13mBuvXDT/GsxjdHEu6WlMJkPzkONywKGBpwiE8mxWwP1FC/jln/Mc51nvepKRqptdqRI1LCyni6zaYqy17RTLqJXl+39f/Uyue79fKY9ZSSsgHTDg1RzcHuUjvUgxVp2TP/JRYFc6uyXQKqVYbfUwyVzp1CPdjP6ThKMuT1OaEh32En8JuAaHmV5xSFPdGJTfmCQ76jCCux96mVhzNKvLjomxNtpIs0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6264!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707010007870750"
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
  name           = "acctest-kce-230707010007870750"
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
  name                     = "sa230707010007870750"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230707010007870750"
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
  name       = "acctest-fc-230707010007870750"
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
