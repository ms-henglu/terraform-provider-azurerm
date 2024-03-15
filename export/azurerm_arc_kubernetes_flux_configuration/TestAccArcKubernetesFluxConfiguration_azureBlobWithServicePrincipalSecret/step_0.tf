
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122335269020"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122335269020"
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
  name                = "acctestpip-240315122335269020"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122335269020"
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
  name                            = "acctestVM-240315122335269020"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5083!"
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
  name                         = "acctest-akcc-240315122335269020"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0ATcdHYTUshOz0ZjO/gIEsXtaOjPHYNb5V+T5omYiC0EVFZJpry1BnrqrhjMtDkz5mcmH0UXZAH+T9j+1L+a6mD0y0M0p+naM/b/Vl2ndd8y+ZODPDw9f3JvX3dlW+7alZMDpU6lP8Eai68WY+z9NrWQcX8eeEfPRbQA+lV/aWablqJByQFOjmfl9KwNEwhqouIQiOFjfBjdI2o7xT6z8IpDAtwlmkE1mcP6qzQsW2et70ayjaKf+ptik6240h60IN9d788ggtm3uQL14RsMW3N1UrsZA477AWjWOvwb9D4tOWx784RYSV0pfbke17Y9MNRTU4dH551shmt++n3+/Lvf9sx1h4sTP8g/4iOsZernDENm2dil4j16z8lTs+nXJINecIzuTeJp8bqmfx16oLt/MqRE4zL9WRrY8i6/G6b817ZZHgbpFk65qL26s5ieTrFtJqyvHTb5f6WSTPM61GTI69FCF4Y7KBCvNqEER55vdlQmDHwX4mLik7GyrFSSkhYJOh75lQsJpAXJjcTMWdl3IW5ASZlFUCKyDRtRvdovwZy13KfIIGWeGylRJmbjk7Kx0CwriRJ5qPs1o0kVPWHSEvhz+iGRLfmmetV4YDBeWkZrolsyPYu3IFKKnVPSYZQbCLqxbZmtKdaJbCoazdbs817K89c9IuxfMcLci3kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5083!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122335269020"
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
  name           = "acctest-kce-240315122335269020"
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
  name                     = "sa240315122335269020"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240315122335269020"
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
  name       = "acctest-fc-240315122335269020"
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
