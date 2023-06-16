
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074252652795"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074252652795"
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
  name                = "acctestpip-230616074252652795"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074252652795"
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
  name                            = "acctestVM-230616074252652795"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5918!"
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
  name                         = "acctest-akcc-230616074252652795"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvKxls84JKMjsOt0/w1g5QBJclGbR7OflJegfVVhxTGyPZiqJbm/RYejEIPG6x2oToAkzRfErkAELIJfWqa64qJX+Yh0yUyK+mVXeoZc/z5ABDiKcZqmXp/1k6r+eP7ulmMmmfW+2yAAyZOxWHJPL2PXb5ulBKjCFUO0fh9+KvuUl86PgNOpyRWqqGF/fxY9+VNKbaxgU+iiOnwFRJ1VLxNhOTXao+5r6P+wAdd3cdY324YfUEU73acyGu+/uFg9yugZBqzrmMa4kD/G7eSlr2uIiiGqcr4B9sOyYZsY9hvvzBQsI4hhyMRuBb8riLvw49cvTwsTiwlPdY94vsRBTe1WWt7y1slLSo3pch5LJ/oZttWgNqqfQ2N/Me1c0ixATCHIATQQeadil3Ygqkl1ABcDyQ+K2ncZGB/VEJ5gXFIQE1pc6E4fyUK4TvP1N/FJ7vVYOLa4Eu0eghv1Pty16aMn0QTjmR0kJxVU8hoCQmvBZNQqQENqO8L+nJrJz29xyGdOszLuF5HuRg6Dw76mNtCaCFzcb5tZvKUQ2YwSEXgVxK/vTBvMBVlZV7nlbxlJzxnP+lFwg5XQ5uuMYZMKiuBHk4FTweG4unfgbYqJV6P4tY6YCYPLN6tSCr+3TYVUQVgZYEVPY/LN9lQPDC/mjIBah2GH9+xDz3Bd1Qq00GxUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5918!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074252652795"
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
