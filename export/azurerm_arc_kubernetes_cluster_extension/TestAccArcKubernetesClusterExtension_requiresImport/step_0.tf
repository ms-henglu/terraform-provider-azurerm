

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031320473114"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031320473114"
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
  name                = "acctestpip-240311031320473114"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031320473114"
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
  name                            = "acctestVM-240311031320473114"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3483!"
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
  name                         = "acctest-akcc-240311031320473114"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtRionspEqh/gaSQv/pcvcO+kZoa75CxPu0DNFYAiCA8t8K0Lh+g6l55MWRq1hw98lib7QqdsuoHFaHWvSHIkepFuJDNXsX1nmPG5h5S0zKt4xedfqmQUOSN71GNa8kh+wzKHTbgdXfmJZrOFRGviFGmsfONDToKzZQ/WTg+qyt2jEkWZuljABPGRob3O/FOAyPZdapR16VuYbFZAnc08/P5OCjE9kgNkmTISp27iWalteYf576Es8TDxIOUtHOs7cFIw6RONiaDdXcgo8Sl4JfNWCUA4Vj6HDWIUSew98ECAgu4kKcmSsd8YFchGEBc7j4rlzzGpgABsvi6d61ny8CCvY1ci/q82Z0gLqJQZcv2Me1Q12w5GcZEo3LfeXaanLb71awPw5VU/3BenMoUl0BkNDHywlaWUpeOdl7dOSr71HfDV9W4+rPA1FMQFTBWE4HL/M1LXJ7xuVZRg/No5ilyMFYCA5FD13jUzd9SZ4Mwdu4xgRwC+wOaJDyKiZMcVkp56ZSqpY4Zpugnvj+GMq5FSx+671VwbVy7jhuKvo2jZ8NBq2xndk3yZ3n9zT4jhjKi7drPg1b53kDQ6GvrX7jXysBQN56evX1nohqZTPmgfkcj6SvDUr5xyk7lHovjoSCDDIe8GOq+/0M6axVYclGsuWjvpNSSy24FK7j1SHCUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3483!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031320473114"
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
  name           = "acctest-kce-240311031320473114"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
