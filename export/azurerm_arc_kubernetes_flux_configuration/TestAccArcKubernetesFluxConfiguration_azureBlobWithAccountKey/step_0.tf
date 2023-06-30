
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032705580402"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032705580402"
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
  name                = "acctestpip-230630032705580402"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032705580402"
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
  name                            = "acctestVM-230630032705580402"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3452!"
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
  name                         = "acctest-akcc-230630032705580402"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAug/Y63s6wVce8PkWayNL1/m/hv0cKirNWbLtzOUTBBdmcwW/FrlmRPLsJf242x9HOaEAsTCPSDRVAZMdTfH3udqO9QfS18tgUBlOqk+xjH9N8Hh+Alw7eNZo3AtCy8lLezZshGLtwPZejNKm81u8id86T6cHgPGLIuU1zSWvwP1MqKFxH9G7GGG7FV2uNegL/4S6JrF+xGU+Eq44+EIq5p7bZR5bzS883MX+Sb8z5Lvd58RiRWqU2pbMFouVHDPCM56HUKHiwwTOBSfv2vuNw4ycgic/vw1pZCGlmouFCnvoCbNQsaLqFjjRP0YKPWTrmP5xwot3/aXfEVCsCqZ5OmL2tlJ2bNEit8iEVALPKzclaFHPZ9LnyX9Org0+LO32B6+/Xohg4m4OdlpAzsJyl1GnRvd9Fi0oMqU1jiGKBILnBlK++aOxIlhjCHpUIofZCZgy5hBG2IporuNpsIytART/HG+ctC3bo/l+0fvnOTtwRawedk5pa8UUZ0/YSH8PvLeW0STuLkDwt8OjHhr1/d2QT1MeBzf4Z2t6u19q5pBXVW/edWhqltkjXD7usJTsjB2gqzZm6OPVVBWeNeTriRL0IIIHsKeooi3owHeZUzoik5nhDsaNYjg9I3w+Z9BBg5Zek6hbGp9C1N5CuDQIArk1UiIhONhKkMNQfHecmv0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3452!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032705580402"
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
  name           = "acctest-kce-230630032705580402"
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
  name                     = "sa230630032705580402"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230630032705580402"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230630032705580402"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
