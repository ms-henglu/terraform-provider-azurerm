
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042916329984"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042916329984"
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
  name                = "acctestpip-231013042916329984"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042916329984"
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
  name                            = "acctestVM-231013042916329984"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1701!"
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
  name                         = "acctest-akcc-231013042916329984"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA56d83w9KGmVJx0dku1XRsbntU5tKvnXbn8j/P0Op5EzIrbxufaN/p048Tx+1bNDKlTXgxvJb3JfLDJUxOhTIh2d3/bN6PfJ68aAsEUmgkUeFYLh/Qm6GD62sNEJ1+J3BppG9lle/RF3GrmSk/a1lhP6F1mplCD0ZEM5lYviACCDzxkkT8K4WxNo9cXp1u+7vrl27UTLGJ9mVEt6hgsvBrYErefCF5ItXatkDqv1B/Y3V6fLnmxL2kq+rSUNYgFDslyTUwCE9X7Bd7BehNaFNc/sVuaRGSyFrmjuzVeJG2+tD/YWS3qA+LfVDh4Bm3Cy4K7aXTjiDv5N047doW9uSAT8NjaKdPnO7VFoAblmM4P4eBDrJuxJ7STLK5qJyLW92MY80e6KVyGWpQFt8tEZ1B6vi6ZoMy86Aodl8g0PUlU7gDI8ZIr1ToB5HRTNSuzhRsEF0dvrhzi10coP1o9Ykd//KKmQ4d1cqpU6qTcYUz1uJ+iIZTyOZa8PmwzONIDqVkXG2bn+H27Ey7n+6VIem6QFRGKUgD65waa+SgCnjj9oDIYq3xLyzu9WpeSYJyJZrOD3+H5Nm79cugzHTtI9hksBMF8+1IV+uN6Cm2LwbJVh5MeOoYbFYCC9GsT9Q8PDcUdeB7RLAm2ki7KdKFEdTpHdpcdXtcDmqbVf3g1dXIikCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "TestUpdate"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1701!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042916329984"
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
