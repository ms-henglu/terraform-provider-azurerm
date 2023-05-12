
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003433010183"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512003433010183"
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
  name                = "acctestpip-230512003433010183"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512003433010183"
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
  name                            = "acctestVM-230512003433010183"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6811!"
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
  name                         = "acctest-akcc-230512003433010183"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzYOSRa9pHUsVPHq+9QNEtqLjKVe8m6QEHfe+UQKjQsj5UlslkHevvT9zkpiQNPDxuKrWHO1Z3Xkm558c5t5clpFqQ5pwX7JmMaC5LGUZZmIJnTaUs/EUcuOBnZY/hDtYU+ocISAQcCkymwfo9KphWCOzZEhC+EBzWld9B2jSN3dnk4eMtSnHoyBAMFsCc8JJryzC6D7Ike3tyeHYxWmeTNzr00tLW/577RnuDSGPCSCl0YycCshnomkyRprcpYqvnnROcfp0KdlXCQSdv9bY1MKT1TclpfiXqc1AXhgKxW7aR6kQ/BiqPBw6a3zT+eoWLaiKsM6OChPYpGBFN5CnjtOYWJmRpWzVi4bNackYkvkGOGGx+andUc7I9jQsHDFErI+jn+lAzA9dF5QT+MOcHWptPWv6owKZrEZ1rHscIvAsZtwKIslYSt8SGHtdWPnLe5RzBC3HlafXzoO6tSkA2QQbHXBijzz0l7uozw8OhbfltR1JlYX3Iw+AjziraILNVUmKbXjOY5SkJRXhL3skWIYJpKJnatViHe2/sJfniGU7A11SwLmp1zqgfXwoHERHdkIokEpMPjuQIu/fSjmq9DXMSqHkviXWJe997yIvAIcnIm7zWbAJ6phK+pKvWldS8y5riX6cCgmWJm76g51BO0u8Rqz45n+VL28sWr40OUcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6811!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512003433010183"
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
