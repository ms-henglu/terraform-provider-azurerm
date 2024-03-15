
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122316547061"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122316547061"
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
  name                = "acctestpip-240315122316547061"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122316547061"
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
  name                            = "acctestVM-240315122316547061"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8203!"
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
  name                         = "acctest-akcc-240315122316547061"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzK0uXc0HQonF4y0lgNciWCaW7GOKwzZ1XYZuTJKWS/8ohpyOFn3nANaF3S1FkjgK131zlIiGdRBPHKM16KxI2F3ep7lwM6C4cW+IsvVF4aH8bMNxBA0EUdzDF/y7hSjVVyouyNj0T2A6FmbLn4bccXN5NBnl2BoDDpCXLxJPkJAoNu7h7UfBjoXbSwi21HLmWZBsrD84Ooz84FQSYZZIpQ0rWl5GLQ1+OwdH6monVPxL6vc/LcpqYE+Pc6i1a3xcr4gGPuIMsnm7ngjws2QPt6XPf3DriwkO0KL7pxBeGN/VgMmZ/mhLv+pRqb8j/U8AxHID/vQJW6nY+NVa8H2O6m+Sz8Qr8otXidJj2dAIcolGu9Bi/7uv0b0W+IddO7ikqDcBVy3ZcCRKdWKCb449GYfSBHI6NrQdOmq7tYtFqlwUrz7vvaF0TyFM/ikb/4j9KZX3k2sump4ivIzIDiAQn7SWKCfyW0YAyvEvXXSE2/PR4LQF7KpV1GmKjAwQ09ccQqqzeX0RcP4pQs5wDQsdMiFquWnVjU2hOhdE/L99xtQpanOyi1BLxipefkZrnD1xZqG3E6RDSIatisXlCNRzdFRbZrq+aHa7ov6pFACReBo7xiR8ziMyQ7uI5c1jUdoJTzCQ4rfTM9HVOY7vyayvOncfucwV4v8UNwbTx7qLex0CAwEAAQ=="

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
  password = "P@$$w0rd8203!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122316547061"
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
