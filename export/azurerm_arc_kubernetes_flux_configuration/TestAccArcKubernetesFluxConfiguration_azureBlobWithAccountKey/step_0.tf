
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025101385051"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025101385051"
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
  name                = "acctestpip-230728025101385051"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025101385051"
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
  name                            = "acctestVM-230728025101385051"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2137!"
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
  name                         = "acctest-akcc-230728025101385051"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyGwLgmWrZnMGx8WHJjclFGHCDCYSn0/2X5/gI22D2Py/GLX4Esza3ajJlqFwykUgmZrgZuni0vz+5sJl03bZndCXvztTWDq1wXJoKWOAS1KNjjwrl5y73losIs1rfubqCnkDAp2EkXF/XTHXcZEqzdZR3azSFDIwibiBkphkvBVx/KJgZ+M1SZ0XhWL1VtC3z59W7NnMSTo2N1ikN4vHi5Ax5StmZj51LZBPhPfdprjhv0VFuPczXakfi/e8tx5SQZZoseK0UY7auhZmDVtZ1gfsoYESVl3VvgrWPBGS+HT44nc/Pcyk8muTifdq1E982CcresRiZjv3C0Cd2565117uDvHX7TgFKkiq63ewe+LlU/bJ1XyaBjQ78geVoNYjRrQvFEQwO0adRoIBqZZCSfojY+ZvhcZbhDhyJJ4MGxnnXaARl8tZgXKJqIRPJhYeCsJKGtNHa9O/bAtmTxpgeiNGRIf4OiCtQhG7e+KwN/82RAVjWj14GSxeAjbfRiea9qp2qa+PZ8ZUkPaWcvPoQRusYCJ4hpXdNhVox5/bYqaPWkA9b31Vft99MEJlYVg6oaCGU5R+/tJBiYzlBb/uVqKEYWp53eZzI279xUike4AeDRpOtWpVUph2Zw2Kc4kpbM7Vda9wmAkJ+MNgTGTuK4fP9lEZQvs34Kb/mPRwzRUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2137!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025101385051"
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
  name           = "acctest-kce-230728025101385051"
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
  name                     = "sa230728025101385051"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230728025101385051"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230728025101385051"
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
