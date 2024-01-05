
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063314029068"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063314029068"
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
  name                = "acctestpip-240105063314029068"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063314029068"
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
  name                            = "acctestVM-240105063314029068"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8126!"
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
  name                         = "acctest-akcc-240105063314029068"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwUPugoOzI3KtiQKHpsQgAnI98GQaOVN+kmSRU2YQFZ/pS1Yef+2Ep0HiC8CeXDfjRfeO0GRKXJxYuHQyadc+4HuCrHZ8v79PqBigAZQuVT4lEOSXSf0F+ax6/T4WEPjXRGFTM30nfuefFMlfz1yB2AZMU5WAjMOe2Jnj0tH/lSB3O0C4/94cRnrrtIrCODf/WOzttQRTrs7URiiTGC2wiT3vUKG8I2tUeLydwx41M+T36awVd0yS7DdQyJWve5EbcTYwnLSqRocj402M3ebeybicvquNKzGbNdduV47jiM1Qt+4ztUomqWwAnBAZzkAXLbqXm8+iNWZkwJJ1I1DnBG683Ls4VBFxiQOuD/IfYmaiwJvDOtBI9YvRfz2pmOtSV0kk3yzoKapjV0w0krWchUGFGD+akxNNW15xdRcLO/cKRZLYT7LkHbhnZhtHsC5MacRYICQgj2fjz2YRwKgbExXz5PFS/lOpCab4z/pNNcjdF7SAGLtZhzfeyKK9fghoGYUy+O8ZH+QuU70ifYcao6FxUzHUG81m8s+W/1ieM3fKR43Vf7ZE/amb9Gn+z3dS4dpwPdm9GOX6ZGDTvlui3zIEQbMQ908aYGLNf/jNmWL56KvAP26V/FFkTxrHQEm+fAnhL0/vFAHsNPYLyvLfNI1NUDnbzl81PYJvJHXHZkMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8126!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063314029068"
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
  name           = "acctest-kce-240105063314029068"
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
  name                     = "sa240105063314029068"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240105063314029068"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240105063314029068"
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
