
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042929257806"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042929257806"
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
  name                = "acctestpip-231013042929257806"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042929257806"
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
  name                            = "acctestVM-231013042929257806"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5851!"
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
  name                         = "acctest-akcc-231013042929257806"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvgStm0QmpC09fCWX4Tqx1q7SDf1F4nyPmIQPESC9EHUZ6ew8FVo9ozVwhS3+q6fPF9Y4Zty6Lxo35MNWrQ80Bqo19yHOF+2PvwUK2rC1D6oEoP1H21pxqLR2pMg6gnzffqTNhP8VyeTK5lOtnbgvHycQ9UaWqh9xwtSRTZjFoQg8MRh9BJgGP4kkVwQNqWYdsOxOXpVVI4R+W3tUs4/hRSwU6clMd1s/bT03Dywi/9wRs833WXnWH96/QGcBjO25hOlSINaayhGtlGzHx0JzdKvvNK8VPJTTYSMXJk2vPSIAwqXEw/dJQW5g9Mv2MSxuWj1os1GqMmRo8KX4OcqekHjlo2Dl2sLocitJfiavm9pLkX2B9eeOkqnWAqF65DyM/l/WLTafdwGtCLTbRCi+P6gPwDxKRAmjXo9VPF2qu/acqNJ3aOgHt6SXoFslOjKffRDKTNMXr+gsblAu5BxZFq1Ji/W8lNKUIVwCx5I7sZjnTZXrxohfFgNYSRpczSPolactLqBc15X3Pi5sKUTXQh58PKyb7noMkjuju7Yt+cFaVHy0zHznVL23/0tM/5rw/wriGdFTL9CmF4SdwaeU0xfqwu7UxpMbtQam7JvhKZkptZ5shjQGMOG5xNywYI3qMSeRGPOUyZW+EjAjh5lXJU8jyB3X8tKmoKw8o2X4OLMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5851!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042929257806"
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
  name           = "acctest-kce-231013042929257806"
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
  name                     = "sa231013042929257806"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231013042929257806"
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
  name       = "acctest-fc-231013042929257806"
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
