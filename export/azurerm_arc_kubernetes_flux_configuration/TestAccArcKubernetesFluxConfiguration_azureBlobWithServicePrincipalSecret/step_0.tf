
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223950079144"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223950079144"
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
  name                = "acctestpip-240112223950079144"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223950079144"
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
  name                            = "acctestVM-240112223950079144"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6377!"
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-240112223950079144"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAx7KX20Jji4JH1Ms4UwZaq8v6W8B8ATjTH+9Ic34tyim+28W/rIPAh9sWiiifP/NPapaf0PCT5OyIvFCxW8LbkOPCYUyehDG7Euber7NQXDRvnJHWjO5P03LrGH6Ck2izP923dIy/aaa42zK3TICiIVLNfgwhuwDfCcjwigXjceIxKY9vfUIRmoRp4nJ6TGY2Bp1AC0hdPW9LGXsyXI2/nxmKkwaGwDnawWv9DrgOx+ECcBl41dnhWRw0ngbmwlZ/s81SsG+U9leM83rVIRpprrU5F6BGWzBGzBwFfDR49FcO9lhr4T5coUIrFq+76syrc6I3FFV4XbfDMsTqzviTx0+060eW50Cfz5zWn3yDBtQH1O04Jc4GjgYOJuuK7CPL/g2zuaGllXWeuvkjy+UOWyAZeXqFO84ZXtXmY82RquhXezXhlC7nG9p9jpN5wqlobhsZbh0I/7zI+wQll8HcaeWN2gcz4g+LFCy1uULogvUKPSZzjJlWVaDyCrbk5RK3S+pH8ZQ9ZQqq9VXTbkB5Yc6okpDvhIK2jOdwUdduqUSK4dqtN2D80nKnBJJVvUBiRwYJmldZQBmpcCQjeOOflQF6VcLwMtBsu5GLIv9HAE1lNsBx7Q6XUT+PNnn+9yhdFBnOoWuIvapWvdF+8cfCqF+Oaakf+1BW/m0YPYZg4RkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6377!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223950079144"
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
  name           = "acctest-kce-240112223950079144"
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
  name                     = "sa240112223950079144"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240112223950079144"
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
  name       = "acctest-fc-240112223950079144"
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
