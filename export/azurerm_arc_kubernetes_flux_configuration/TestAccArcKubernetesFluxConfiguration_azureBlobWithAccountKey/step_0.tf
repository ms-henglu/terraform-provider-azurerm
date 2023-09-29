
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064404775953"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064404775953"
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
  name                = "acctestpip-230929064404775953"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064404775953"
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
  name                            = "acctestVM-230929064404775953"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5644!"
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
  name                         = "acctest-akcc-230929064404775953"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsfQNk2FF6eLknvYXoCbycgH8vDY3Ma1MRdxtr7tnuBejBvtc/IySe7qgp6QTJMc96KMMQgNKbEmlDchkTlW5oX1/FWpTQutteQs2w1C0hDqQXwOLUL3gX1UZrzalAzYlVEPEdxWIOQCTGiQPgWkj5/+RwRfPxoqS/gEtFPAisnQgT3qlpxU2SuKWiAPDx7Kml9A++bh9P91C1zSFAFUozDaISiE2eFTGS1tZJiqnbSJ+KiXthA0IGlq2i+6zxdhMjcyVTZmOizQAbcPb6ed4b8lk0dlInq0rla1se4NxlF4cESuEq4hkrgT6IRQFWbIgo1K9DG4FdmLDihPthsrwJUqQEYx8/Z5JYne9ck9X8SaWR/V5img5tbzwqTUpVDF6/jl+ix95LjVKWdz4+wW5lfvlzrgrKYB6ta/m7LY1FHHpuV2IdWCZR+TKvrN30t6egnbTDdTV6x7v7hiOxQqHzQSQTtAx8Ke8dRSAg8CjRWmBRti5JKvpEqP+zZwHJ8mNjbyBa1UNIyBBB/fzM69t4sC0cSzSDDHiMmWT6YIIFYVt4KsZBVPKO0VY7grAfoKDnerezlxqQhnbhhTPqXybPTFN2LnlyHXLubrRajPybbChJDhMgBfyyPHEOrQ9U0zTTsA7Lu42itdWnoX55uKdw7IvFmrzvDPSL5GZhOY1ADkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5644!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064404775953"
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
  name           = "acctest-kce-230929064404775953"
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
  name                     = "sa230929064404775953"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230929064404775953"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230929064404775953"
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
