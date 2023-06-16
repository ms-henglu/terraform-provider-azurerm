
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074314470824"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074314470824"
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
  name                = "acctestpip-230616074314470824"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074314470824"
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
  name                            = "acctestVM-230616074314470824"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1511!"
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
  name                         = "acctest-akcc-230616074314470824"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2TmBbPZD54BerDhg6ErxhZGvmXpR2hX8bqFl4viy+qkxZ35ATkutAgreVR0Y1VAMTR2At/YDKvdQ5xrHmdg9rnQ52Wn+DhO7YnDGL0af5ZDyWw8d/AxFWRBfBMpKAebANe2WyMNunCwFXvr/qVOyGYm+CJx8v7HJozOgfYJQ5ARqDFJe0NQkOFTkwCKdmvnd8LPyAGz8V6UrG+PWdizxM3E7wHZ/rl3t80yKWJH9gZy4+5tBSJloXELZDMprvCSj8kPPXCzQu5zE1BST0M4qCots2znXjYHnYQI9IT1Wn+5eVzyHX3BmUCSBw7+HV7wn+/Ci6YCKAYfzRkuzzScVV+4siLtpXG//0+15xrubw7oURm/wK8zMml2RHYJ2cVfI469/r4NxYZwoh7du0X6H4RAPKD1DFj6+8BWmtprnKC78uEpUTZu3lAIEc0vKrGSpZIvdIocEq0+vzyaQavxD4omlL86n4WAgRrnMbPYofAccB1Zfzgs2O3OaB+R3B0o40vxzi0srrAs+7fFGpv8qfqpKRE3qP3wudAUI+GWiM1U8nG2d+SPQ5EG0u8tzM/8+I6Mqd/ImfuXF2DtSc7JYyLX6jYPgQtcKj3RL6A87cFVj6wQTl4NvJCMMpVPkkkV9UtaCqA/QLN6IykLKyhHyi/2rLZM6tD86K/vOWMwRai0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1511!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074314470824"
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
  name           = "acctest-kce-230616074314470824"
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
  name                     = "sa230616074314470824"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230616074314470824"
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
  name       = "acctest-fc-230616074314470824"
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
