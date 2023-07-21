
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014523912039"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014523912039"
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
  name                = "acctestpip-230721014523912039"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014523912039"
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
  name                            = "acctestVM-230721014523912039"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5949!"
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
  name                         = "acctest-akcc-230721014523912039"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAs+aJ9u7NgdmwfjjXvW1yG8TxaCNXVCGfpDPRXW7HhM4V/dAR56roEiK1nZnkD3L4UImrjgt/HkDQDAH+DqH5rpKNLX2YxcsNVXGoQvByDcMmBaRgwZ2vGoBzX6HJZ0bS98/q88ku2twna8avywAf6Csf+H4wvCRbwE5W9PVKQNSpY5UHw45HpQD9Z5LSN/p+qyAGzZTrLL6RlhA9yVsV7n4oYkQMb3CqHG33h2A+Ep23tdPJz9+9mRwyFhO9ezU5l8iDoS6YPoFAvd1V4dLhuI3a2eR9sHtYJ0ZgEugj0mX4Jn42I78up6vi4NMOkZY4o3/uNkRRHFuuKPHjPLUUETPdHqaCZPkZWK3mml+hg76DekxS5mNO/QdO0/ahuln49S2B4TV0c/7+TxDfARhnCSaTgOFX3iOMN4nzjHeoAfShvBziJkTWZ1rhNcxm71fgLiWYdxlfUDqR0f0J6t6u3PwWDnSGIRFV32koC5p+Wyo58nMmYmDZ7Dx8eKWT7H4j12nwH5R8N1P/EykqZBlVs7vydKWv/dnv/YRwGf5yFhAXtWGEmplUw1mDwbzjELXIFKJGK8DzoJiccufDC/hB+Z4BDOBo9qons3b+RBRktsbHAyxklnPPPjOeJ2YqAf2CXV6FL/BAVRewIlWY0neg/X3hPTsXUfXiXw+JXI82t4ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5949!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014523912039"
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
  name           = "acctest-kce-230721014523912039"
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
  name                     = "sa230721014523912039"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230721014523912039"
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
  name       = "acctest-fc-230721014523912039"
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
