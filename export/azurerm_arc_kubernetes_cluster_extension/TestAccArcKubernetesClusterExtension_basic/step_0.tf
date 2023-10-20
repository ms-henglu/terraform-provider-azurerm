

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040517685578"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040517685578"
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
  name                = "acctestpip-231020040517685578"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040517685578"
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
  name                            = "acctestVM-231020040517685578"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5511!"
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
  name                         = "acctest-akcc-231020040517685578"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1C/7OOMbg6Kg0ggqBNiUyhwX3j88EgmQyYNx01iBnQQ65o+F+bwelLJJtkDWxCaixPpmQwxMu42bzCIJtpely+6gy2Oc2TQUzLpQfRjfqQb7yNiQLSNQgFA3bD1373/P1CUKEYv732ude+hY4WnGBURzp6PT3CIX08W2/kn2YqA3BCs8wFV1p9IVFKajev5Ina4hfOFFlNbaU/gnAucYhC0BMOrSPidGomNIpdgN5JKxGIcVZWbKjA5TfiKB0rBmIKjRgG9yIBNuAfD4D/M9JdATMkClc0p3clZRuBMZA6iILcpADSIY5l0iCHo8bNxHAiEtrdC1HxG84qUPR//sDHiqENDB/EoGtuJI2VX/iw1gkHsKczm3o2qpZlhEaDO9dEmUaSF2RYDBWx8gqett1q0AqUBP/3Fx/adFYtI3+wHgOqGbzkETMz/1e+q/jHu0HMqmU8VVbPnpPFxUc+9O4oWDPZ77k5K1fqB9Z5RiiUhR1EP202PjWheVIn4l4NWKSVS+gTZXrch5+93xsYVaRjj26Xc/ju+ECBujT0lnQC2SLnD3MPLhpWiFQIPL+gtTzEdZnnDWV2ZVVJbxnu3A9cC/d2N+LgXrP1Z6hW3Yk/5mziKD3f+v+BMJJo2S1rfrcYCmCFT2DiUssk2gw3wNBHvxBixlrVYvUCWKPQdYR+8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5511!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040517685578"
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
  name           = "acctest-kce-231020040517685578"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
