
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003345220142"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003345220142"
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
  name                = "acctestpip-230707003345220142"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003345220142"
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
  name                            = "acctestVM-230707003345220142"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9919!"
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
  name                         = "acctest-akcc-230707003345220142"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuYbzx4NWS3V1QFDqVx8BI59jFFKyWq8uwJFPWYyYm4ELAwkwUKFvqL3B5/ha4FVU91tD862SGqQDhg0Z7SaQXbf2nMt6twaK5hOSqD3f8GZLBjjmRI2P39Ui/be6/XsbMObNpJcZn3a/qFZJmS3dvUIaWm6WsFQ3GUWRX7+A0C4IoM2/3DSQv1UPMK802hlyqdLSY+JornT4R8vh4oJu+M6FUm8ndpqWkb/8LhJwozX0IKXOi5nTUU0jhGxzBPsLhX3SE3LmPoreQrOCl/mB9fsZOscNrW9oRhDS67CNRpst9vzczPgAoWpvU8a+GpaS2tLlmjDTwS0tkAdhl05V7fuNlEWIBowKIZUHerwe/wTa+69RcIkvN1oRq4HdkaQIiC5yCFU097zi3Th9A85tdbDK6+3u/WIKSa4fWYppICm9tg8P46i8NvIQ1qv6aQaeDbM5MQypL6OkAIwNUCbePc46hTx2kyU/roEQRHq3IA5c90NPZ+xKPv5BQKAo3QXQsvtEELjOjdDknpyKdBejuPLQ7gO1/Yf57T1ha/vCKOOFDSkc+V6Cdm+3Zp1LT4hdYNJ2VosH9aYw5B+z9qZtQ1U348QYenGXkV21NrxJj/Q8S81ye+76eeaQ3JXwenjgLZ++I96O39KeuaquSzGeh1gw6To6+YfX0WK6RpHW1v8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9919!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003345220142"
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
  name           = "acctest-kce-230707003345220142"
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
  name                     = "sa230707003345220142"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230707003345220142"
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
  name       = "acctest-fc-230707003345220142"
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
