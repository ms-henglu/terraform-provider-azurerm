
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011154014114"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011154014114"
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
  name                = "acctestpip-230721011154014114"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011154014114"
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
  name                            = "acctestVM-230721011154014114"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6175!"
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
  name                         = "acctest-akcc-230721011154014114"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApOsZbOowsqGLmafH9YWnmNDMIKsfzrI2/i9I+dlkQPHeF8h5e3DSa1gJTRKxM1ag2zYmyD/8Hq55Kb086nKK7rQPBttb09tsKDr/+QFPsn0HWfQHdKmvz65GZT4zvlqIHPO2HRihzBKEBuvLW2a7ZP/82oTJNS3zaCTXyGcQhsacwLkw0SMcsHuo4gmcXuT1g7HzMd7KTWhqibONFmvsDYNfT+Hoi8SJNKgXht7aSbO/lsU3EmAXkYcuEyMgSneEf8cAGvoR16RAugNBXDCx8slcRMMNo8v0UW8veWTnJ9kuTzNxNGjQhvxWtHOHNOv1XZc72zw6sr+md9ngpbJr3k8qSYI/bnsmT1D+n8rkAiuZ+Gbr6N86D4Iw7H4zsqYpTnCjWDT7835pJpiXwc1SgGHzXao1QQDjY3XjGbJsSv1u1Qb9zNb5mcG/4p0yk/ph4IXSmukC2Yverx81/Upgz/2KFyhy3y6Y3xmfJC78ovQjgkqEkXSG/cK9c5VHU0wm51T2b2Q7KO+ZMcfRaqaOwDgeTo0+76DGedULgK9ejpusk7VsQ6pu7p+iM6xGQL+PtYEUt9sVpyiPunKy7Bjnwg3ikjO5nU6rM0Ug2yLN9lK2VS1umJJJYpjvHyeqG1sRMmOzASF+kneY+8Efw16rRZceB0sJFSNbsJC6twlttmcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6175!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011154014114"
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
  name           = "acctest-kce-230721011154014114"
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
  name                     = "sa230721011154014114"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230721011154014114"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230721011154014114"
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
