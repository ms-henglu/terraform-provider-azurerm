
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031358649782"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031358649782"
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
  name                = "acctestpip-240311031358649782"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031358649782"
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
  name                            = "acctestVM-240311031358649782"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1246!"
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
  name                         = "acctest-akcc-240311031358649782"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzepcC68SSk6vBgrqMrecIOS7M6lxNS5bnUuik8Lsgva0f9KpvXU2iME8MfWXgjq9FrP07BZXWiXx38kAYeb4WKcRNA+JfyyNidZjwVGh3tzkBhYPCPnAcbC/xw3HBG77kEOCLRs0Jl69ob3xo2yZIeELj8eabT0/gXBScq7qbs2sY6TdtZ0PosIIJEuQfeGaZW7qIRgZQJl3Fo2n6ODkw7EnYsDrT6NM2fwAViWj0X1MzKmEc3CiSl1+6FsjYg47rowSUYFsmZDy4vqTE5Ok/KT7IxZFbVRchFF2r0fF1lKY8OL6bofzr+YLC5DmZQ4V5xumD0cLVaZPjzN1PelG6OZg9yg7993Ge5nKX+4Ry3g9Dm9OS0Mlh3o5KRtYqFLB8t1mvVSsamIqmTZ/XGpu0d0VHtK8DYp92AozjLwl9HkXpztdvEHl5zsrDrMIAvw4T0ai6oAHpJO7Rbwa9+BsNZFwCDMj6neNQWhknDJdwgywUVM9CfhUPKOo49SmzxD6NBYoLpuCQkxeuFMFf1iviQuMu792RcUXzjz+E1NQjQu9ErAzZC1bC17cePMrGl0VD61a0m/w5v1cgZOdmBvYg0eWPpNE1Yf+qKRfo9KK5n1o8es9fZAvkYr2OZNL67XHUvucE+D/jmMxxl5uxrZ0q6OErFQpyZjK2/G2gnXucIcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1246!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031358649782"
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
  name           = "acctest-kce-240311031358649782"
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
  name                     = "sa240311031358649782"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240311031358649782"
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
  name       = "acctest-fc-240311031358649782"
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
