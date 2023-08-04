
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025424527540"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025424527540"
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
  name                = "acctestpip-230804025424527540"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025424527540"
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
  name                            = "acctestVM-230804025424527540"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7902!"
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
  name                         = "acctest-akcc-230804025424527540"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAr14h5rkK/cpPbnbTFV0cu4RvN1Bz4IagBgkNR7NuRi48vhh6rPa+1jA820AzNySGmL0eyy/xemUY0V6DWkvhBn/jDrI0HawDsNF7EZlfj+Mf6g25+dOwvQJ2TnNUA2GEY1t3IESQIWZnTWZEW+47JnaKinoF9k40dZl3So6o5oGWkRbDwl0S4f/fAhb2smgMKHolYyFFE5KKmcMIdoI73QbeZ1JAlp52JVytliOIxXQqik/KYDAdzSN2WDmiFWQAVvHj/QQMYG3dF6FlyFr4PrpCkeTxfXo+tCFXec1F2hldLlyRNHvliRHVXkaD0zljnxVbaC6YBadkaoaWe1cv68Dv53VsZgM8+Z4EjwTBbMiQfgwUXKq0MHqeZeY41ceESYBZz+d4ZSjQ+7FWGQyE7IQUWSo4HUfDVnceywTdk7ephUM6R7ZiE/P8dRfqra4wg3JYD3bKrU1UgCnK/sBnFfSz4Wt8UxeNpQNXOHPQyXXWv+a+6TdqsIP8ke5pD8xHRlbxK/08pc+baH0i2IwH/1I4gzloKOsnJwUwXuASE0ox9TwmoaTXXgUfr3PSGy266E2PEXYzYT+BoDyci8lzW1CpvT13ZhXiI52xuN3cnG1aHkCjKdZHnywE9JJGI3MEveNocf5CkDKoQ7UO2XTuPLQY+CzTFkzws4DhCPl/5FkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7902!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025424527540"
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
  name           = "acctest-kce-230804025424527540"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
