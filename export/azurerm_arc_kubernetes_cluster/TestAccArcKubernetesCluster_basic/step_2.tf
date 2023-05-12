
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010220857154"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512010220857154"
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
  name                = "acctestpip-230512010220857154"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512010220857154"
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
  name                            = "acctestVM-230512010220857154"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3658!"
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
  name                         = "acctest-akcc-230512010220857154"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAv+JSefgiZjTSCz2UD62uYgxzoAVESvPjN6cN4eIhNTdcPvehqB6SGO0e4PJMZgmSeGmRbfTF5arp7BljD3RAXS2rUYWQQ0KCMV8hT91+3tuGBqmcQ0CoupEbbxe1Eaz0T7AXBRdol4l3xLzvwK9qZ/w295G3onX7dJwBXhWfg0EzhuO1gR9P3snAz30OpfllcC8knbw/aSH4QASqSTLnBJSiqrR1ViuoH0Cn8yXmBSJySFjDIDJiLAqjoIiPRiV5QmLpCQKmy6fT7OL3kNUiUkuljH5llPbP0XvwYxg38aSIT3aNQN/FOUIw1Fy0yX8KHp3XCejpkIcQQHGfZnLRtr1rwuRK3zt2fEBAS1snX3xilVNcgBZhrlC6owjv+vkTsM0bEHrt6iB1QpVh4DBJw88ZKF699QoTRZutYFyVqi34bvk1dWE3ZD1leBzvcY78DDEfr3+0/Dt7bVrx1mNU/Fw+j7VuOrIGkDOeBckuZ3mMiPRLRVtpjgWK7TVQV1ua0hoBJTbTT43SAgPnc6U1yUiMe0DHB61yfaOs3x2eSusc97CqYIA/ArcfVqetEQIDjy9VFfazRqUx5r+eEevP1H8VXxJNdwZuCmnrWDzzHmW24Ff9jaOUZc/C+oDMpmUdBPDeSO/f1OB8RBV/ypX1FqJi+HWmH8mFkhceKCvynCcCAwEAAQ=="

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
  password = "P@$$w0rd3658!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512010220857154"
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
