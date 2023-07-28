
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031754868161"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031754868161"
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
  name                = "acctestpip-230728031754868161"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031754868161"
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
  name                            = "acctestVM-230728031754868161"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9481!"
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
  name                         = "acctest-akcc-230728031754868161"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApGgNqiDA50uKVC8HLSY7ia4vwT/B7PEXoPMI3irzw2qCDgHqadvWr0paV407O/5JfC80qRPQBoB7n8tVm3oM5m7WegWZDxuQcj74zm3JpLDPq+QjhwmDawnoGHxl34VKVVYbtTu3RUkODswT3/gjKymteg+FvPwg0cHNRSHbMU9zbazRwUs2APip8WLo2E2u+Cby6xsXpv0EXYDTceZFx6c/zef3q+cMzDtRoBLOX9o3gZ5Qa923ko+Xolc4hUkP7H0TmSPyPlh1rIVy4Ks0QLN+YZBitMAaVqh8sDHXB+nBkPOM3NoEVQ/B72eKZ8jLZ9wO4YN4E2t/EKPpqtDlJXCqggvEvJ2SjQTjFlRQAejE927VSxEwEj+9AQBCfUdrW8klNmnXfIyrU+SZd+O2pxoOzIou2vvyCOnZW++d3ouolFHOh2XBxmkjv8pZDrC28kL9mq1Tt5BHG5lxIUQM0xzCfQPSScUB5Xvmr3GknUMxyQQBD50URLvEugUBdLwH5K206pOM4h7pb70Ij7AKDzGK7cBAAO6qj01cMSfQDAfbojDFJgcm4QLV9msXe8qQut+vzq6DqJh/BKIJNtD3FXJF0Dc2lCYzoRASouwhNdBTgRra4CJ1ybPcfPOnultrFSa3p2J+ZyOfvTPW14p9PHffT/uh2NcNxTzR4YZjFcUCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9481!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031754868161"
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
