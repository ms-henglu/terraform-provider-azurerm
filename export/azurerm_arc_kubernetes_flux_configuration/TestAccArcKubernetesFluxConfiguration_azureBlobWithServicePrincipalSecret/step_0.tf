
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063316981982"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063316981982"
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
  name                = "acctestpip-240105063316981982"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063316981982"
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
  name                            = "acctestVM-240105063316981982"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9753!"
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
  name                         = "acctest-akcc-240105063316981982"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAznnObpTMMXLOtXbO1E1/eoxMDnNwXwEwmuOK20TrmFjB9F524zRGsd42SKBaSzE6Zm0/uQTTMHgg891Cf56k9W6i8ZyW6UFalZff5DKr63voP4NTWyI4wmh6a4RJ12/WDGOptSccHqrdPZm0BvWvoYJPVTVeHb5aW1ldgFsy5ZLfUUz3Sua1NrmcXTKaTunBZFnnlj9yRaD+x9TGXokJ3blvTZmeuINRhkknby0OsGdGaSVEwCx9lp2nLGrEoHp1AC2eLgZofqTUbALFhcD53nRTQX0HSdV62gB+YNvxaF+JB2GAZi/F8hyCdX6WPcHO4EvBeswuYTxotQhu+zBlvfx0kz/FXWZLriaCVVPbcpSZMGDCcyo/nktNRAxNNRmBoPxkExgNv0eqEp/TvDPMLcS/lkWLEkPY2IklUK7tjOERdy4qGSFAoYR6BHWITSN0mPhAErkUQKOiNsZ0qu0sH5/FOeLCsFK6jbBMHUt0UYgfWIlJy0dEheoKfhFMeG4G2ljUfHQ9KKXjVaSclIC33iFP5CoJapYQftc4npYaMh5MV7FRaZzjq5I4DLT33QxotELjrLNWp2j2uvYSVVYY/oQh3TiK3Pk4Yqe8NiMyEA1THXeyeYDba9NtSnUYgjyVP/Auts7U7fmI947g/H51Kza3IxOzRtVVxYgdvQg11DcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9753!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063316981982"
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
  name           = "acctest-kce-240105063316981982"
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
  name                     = "sa240105063316981982"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240105063316981982"
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
  name       = "acctest-fc-240105063316981982"
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
