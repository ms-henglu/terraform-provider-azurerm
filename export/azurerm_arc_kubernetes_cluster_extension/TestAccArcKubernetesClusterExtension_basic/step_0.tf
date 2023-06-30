

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032639507657"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032639507657"
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
  name                = "acctestpip-230630032639507657"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032639507657"
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
  name                            = "acctestVM-230630032639507657"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6131!"
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
  name                         = "acctest-akcc-230630032639507657"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqUeyxIpcdrAcIrm3lWPwRjkONL8ImQTT4lFyToxugN+AlXdae0VyUoEsIo7aCXSqPYT0bf6XmvIkwucOmT9cvReB4IYkxzdMi//TmabsTYPHpDdMQ9xMsIlowT04kQANJ4XmZUpnpJs/yZSyEMbNMri+YZffpEkeCtHwNQ8svgV706PqSkhQjxI8KVgZlzimWm/rQX4IknLDNR4XGlEWlYdsxvRIb6m28zcBbcjrh9P9C7Tu43pw7piOa3hRctI2MrLrolOVFc6AYFBWSGlcywzo26hJCntCnDVKyXdXSrBk/DCRRn85jLZU6w/JMfwvyoBeGZkjZnXP8xeULcKKA0zjgW9Rn1f7GsKu9Cd6qEmxkJeQDFDZ1+z8Sw2f7YmPXUIqOYOO0pzbFHC5gbcySdyCBHXbwgW2PNybDhKZEPaMLpI036rAwcrj7iBVnqM+4QJUgpY0htehOPOVxGXRcc4ItRSbGlXLrjCQro4UYKM3fc+60z+Qnz99vneeE1MPUG90hShU5Zc7nbkPl53Cl312KmSjArZo9uv8PXjzgTbIGhuI68ZWK2hMfEHGZuGg9sXYTDHMofO54pdxOC0D6gcCkQ0ymK0lilCWM9AOZVUNoC/r0LngUkMXUEd/CNVCFJoeEuhNcfcx+/CUkPA8aPQMxyYcynxtyDYcOwOvfEMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6131!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032639507657"
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
  name           = "acctest-kce-230630032639507657"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
