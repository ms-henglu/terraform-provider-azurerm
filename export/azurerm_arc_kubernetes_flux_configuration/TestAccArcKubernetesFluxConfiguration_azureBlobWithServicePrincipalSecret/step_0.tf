
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024050510181"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024050510181"
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
  name                = "acctestpip-230825024050510181"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024050510181"
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
  name                            = "acctestVM-230825024050510181"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8515!"
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
  name                         = "acctest-akcc-230825024050510181"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqJUPA8TUp7QU9SsvXMbWsN5zEAoX/D9wsCeYUSZhI2uTJqi2iZhZqH3t68BZ8h5nr/2peH0mB2bwSPFPA32z+S0fVVNlpMjOJ6VmAo7izBuG7S5T+ud/pAA9Xlc+NnHxsj0qHRbXH0/AqIGlA4nFySH7Llt+js1MioJ/P0qPlQNwJGIGXtz8w164RkaQxcD1CPDe7G7gN2DME1l28UFquvvnoxE0O2ax83rnrnywOLi0NIz0T8UDjKe1/CTKdPH0zPlEeYxh5b4u7pjXhDf0uwaofu7/ZnuJzMCI6A56Oc/OXC96todTydwZYcoBk7X2yoa5SOeVLy/Uj0qtdqFk8yIWALi7AC2FVQCNv6O9sA5tpW4IuRzhExgC1RLT7XH2M9d5E1puAL9vAe/VBkoFjIGCC5BSFRd4g2wKxrKgAa7Anc1wZNtfBY0V6rNfTMjfNOoWDfT1BEX26TOmGO585dYpQY59WL9593tYP0tmIX96eMjmXyi0q9zkbwAjIUk2t9MIAZbe028u6rwJ0cc1VP06kUMRd++u7V3elbL16MRmavppj4hPc7r6uhPhj/xOUaMHs+5Tav1DlY6mNWUxYPisGAdaCOmOIqjmx0psEZCqaQbbKCVlSJhxw9AuvkdXKN3Ic5+QFcZ7MoZ1oCc2xwOVprTEEiWPXIV1qjycJUECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8515!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024050510181"
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
  name           = "acctest-kce-230825024050510181"
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
  name                     = "sa230825024050510181"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230825024050510181"
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
  name       = "acctest-fc-230825024050510181"
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
