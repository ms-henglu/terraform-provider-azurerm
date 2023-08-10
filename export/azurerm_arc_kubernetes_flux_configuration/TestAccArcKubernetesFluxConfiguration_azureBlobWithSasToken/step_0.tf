
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142953570289"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142953570289"
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
  name                = "acctestpip-230810142953570289"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142953570289"
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
  name                            = "acctestVM-230810142953570289"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4299!"
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
  name                         = "acctest-akcc-230810142953570289"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzbnnLq0NxHGMXi5kcm9xhSeZtA7umUUEl5YIY4oHLkf6ZrpfCKU7fxsHVZdTQlNhIY18Lg7SzY0I1/1kvkC0R7sUxVtjbVvUfbY5oNMhHsGM2+JD5YUugstius7qBANBaXHqB+ITup1py33jnK37EZ3AxY4q+LKH6Blog6GNAloIzyVxqTdaM5ZRlTZ0efR9emBkiYOlAghRkoEcYErXo1t40JgF9dpAv0W+rsgT+MzYJv0IXuATrpKPOrML/HSBy4NVfi7dY7FpHcNnvmZGptFJ/lAN+bUugzzq108biv3SkRCf/8LznSOWpxlgS44AQ6A+kkCn5MLyTPd9PMeIdiw0AaDJsyZ/y5EqKACQ3Pij4+bYc4+i5w45MXTCDje6cnKu+mZnTeJpAOnZDoijpIuAtBH7PIpVfAl3W/p6QEpGv+8i6B8ks0i3Fbc5PPwIeYDjVieep4F+cEcGYKoWzCBOQqMY2GhEIQz5tDi5kg03fZW+2QSUBrRuUPoBcTTFi5Zo/DU9HpV7PxOXn1AZkCwdD3rkcAxHl2U+Tib/j3ISYF6p+n2bXRai8zwCyjLEZB3ffHT0ViXKfUFaeBs7+VtMX5GucyS/cEgSK0LNHQmcuokWlY45u7vzRuNyJLeNJy01XmZ2yf0KV3texJpQ6i6+PKZJBZdFAk9hMhzYph0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4299!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142953570289"
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
  name           = "acctest-kce-230810142953570289"
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
  name                     = "sa230810142953570289"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230810142953570289"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  https_only        = true
  signed_version    = "2019-10-10"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2023-08-09T14:29:53Z"
  expiry = "2023-08-12T14:29:53Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = false
  }
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230810142953570289"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    sas_token    = data.azurerm_storage_account_sas.test.sas
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
