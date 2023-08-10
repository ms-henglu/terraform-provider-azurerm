
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142955213580"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142955213580"
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
  name                = "acctestpip-230810142955213580"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142955213580"
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
  name                            = "acctestVM-230810142955213580"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4807!"
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
  name                         = "acctest-akcc-230810142955213580"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArcW5w5edwEh6ByN1SRFZRQ2gUVDbSaTRoTkTt4jtDMtAWzAuCnuHnM41crtibFduOXu65y/GpCr0LgZh3F1AAzBux5Rq56WXiorUto6gHa+Oa9fz2BRFiumpQ0syhFXEiBPeyplGAl8ZCTSfv+NoQ4bUDWEwtsR/pt6/1JaWIhrM2wCF/H079xcxuLEMjeZgKXlfYxImukgCEiq//r8WDOVuqtwLGDlYYSgW86E8Zs9M6jW+TsL5VaF/2sTCmE7SxlF3ac1fIpk6owy9lH63VB3boOCL4prjxR1RcBvHaUTZc+rvwj7BXyn99O4KV4UnKLZ3JlTzxQIqXfM0w2ijNZs6KNnS70vEVItv9gUypyzjm6oPFUA22q9S8c5xY45joMSpN7zzbUjZRzPzKUaMMrDDWxf++TS2dXc73K+ezKk2xw6dCm7DrxChq3GJ7eSs0R51WEbcQ5a5HPmgcsCljzT/0wSHnZzsGbO8Jtp5yJ4tmltTfghZUgYmhhNlungq/7g4CxuXCJqmtgAgHlb3JFrc9wzLlVXZZG96qEEkjvlGqSFA1ZWa/NMd3VKTay7dO1KShdtlD7tY4yACXwuXh7E4vuvoBkLb+asYUw6cnQxQxJcppmkQBYOhnCTu0z2ssulSBgYLo3K5cXimzfdodDetr/6fVJuNc9NlLed70PUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4807!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142955213580"
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
  name           = "acctest-kce-230810142955213580"
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
  name                     = "sa230810142955213580"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230810142955213580"
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
  name       = "acctest-fc-230810142955213580"
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
