
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064408075866"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064408075866"
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
  name                = "acctestpip-230929064408075866"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064408075866"
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
  name                            = "acctestVM-230929064408075866"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3329!"
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
  name                         = "acctest-akcc-230929064408075866"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxsjS23N4+4OreTAHw9q4HMB09UduuxLfZwk2Lc9XIdxNziMx7oDGnFMjYZ211sUC6SNxh7s8Ub+3+k4njBjifP0I2PbB2xwiWYf2tajrV99OlY78ldSO8nK9TKfQcEoQBr+JG/5uHwi2IDh41uv0boxqCDbXRsDHYAOF5JVLtMi6CDX8hLH2dd7N1xwbVjh3jxhjEGmDqj4fjvS2ZCzIey6vOjPcGBCOs/Z6Hw7W+3StxxiLlEGIz18sGbIWnTUIadnDTdCLBC5/js3JK7xBkhMQb0+rub6W5KqxQWZes4GpK7ESPfhQ4KlZQSAxOSFeKNdwaL53HIL5enAzBClzNewy/JsXBqVJ1CACfZ/+1QfcfsRoRNyZCgy3E5twzjpI+6y5kIEtFzlLQjJ51xnCSAU5PJ52XgQ/aVrEJOLp0c6P7uQewd16iHSIGDLlgls/S5+TC8vaTYlCtHEyI9iMBieIqy2ROzz7LD7xtaSmyNueGfiGST/qzHYM7ZEzN4bcUm2ez0PolGbWQe4wDLcwycH0lUPhyzOUBnEsIVqZQKjfl0wnRHEcO6VVmnJOQLy+EEZ06Of97L9mRnPEY24oZhhL+4/39LaOq0kofFrUFbqvbMuV0uBtr5tRTRsAu/I4x4kv9nc9tpYyx57+LofhqsjNytEMqU9NVihzld5A3c8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3329!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064408075866"
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
  name           = "acctest-kce-230929064408075866"
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
  name                     = "sa230929064408075866"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230929064408075866"
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
  name       = "acctest-fc-230929064408075866"
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
