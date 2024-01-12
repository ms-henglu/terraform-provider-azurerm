
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223946507001"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223946507001"
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
  name                = "acctestpip-240112223946507001"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223946507001"
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
  name                            = "acctestVM-240112223946507001"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9299!"
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
  name                         = "acctest-akcc-240112223946507001"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxGzJWVM4B72RG5Y5S3Eie72k3L6LxDPNNVZzoEY52nkJKDbPmhB2/9O13BNKplxsnL2yQWfpneemIveLWu5SxsPKwy8Ju6g67bw2ORvzv3H01FPN4BpRcoQKC7eZRPLNsYKDxytMw23mA/73Z2x1ktjNxB3c7dJPhjeDBhObEScY+wvMT2FyTOaCO2oWrydKg8dFTGp87aNhZzmjI1rkcChXT3yW9W+t9WCWddd1p7ZU2PEeBK1jlhGKBCq1tozq+Kg2QNWurjgfMKa5lr9B7Bme9SCDi15Wa2F4BcoglAwzTy6gCYzu8L+AdEQZBl/Olm3R+eBho3lEJlWDh9yYPiPoC+7GTBys5t2KA31wbtuslmyAD22UkqP1STv1XHmJazkqnpOF+31xJnfl34NT+ajIisYGtN+ZPigrWzCjSpuB7hKmzvr0Q8qAf2o8MDr/FQY1ZQbGRuY4KJ4Pt4yOlZzjscz3lE3i7wI1bUwozQVihYOdSm+Y8TzejFh8KXsfj0QfIowgXH7dQ4c3scGS7OUteDlUnoOJRBeypU9fVcPbKaWdUtiWcH0KFS5UcLzBvQfYCLaju91W38Fg2X/3jEDKEXVT/vyA2X6+73uOO8Zb8FNCcz3U61nzusrg9qbm9Q3MARtzl+Bkd0I41B9IWpojx1RMsMUud83yePeuXYsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9299!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223946507001"
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
  name           = "acctest-kce-240112223946507001"
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
  name                     = "sa240112223946507001"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240112223946507001"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240112223946507001"
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
