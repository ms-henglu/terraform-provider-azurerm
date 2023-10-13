
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042919495028"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042919495028"
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
  name                = "acctestpip-231013042919495028"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042919495028"
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
  name                            = "acctestVM-231013042919495028"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6286!"
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
  name                         = "acctest-akcc-231013042919495028"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtRyaC+Y/+Q/z59b51ux3mnVbSIjOGMWo4HQFX12deqY/aJgBy/krc4E6Fc9qUlmDIw5N92kfnqA4oSPnjfBv0vigbKuusUDEIbOYjpNzc4ZiHwRon7hzrlPtG2FQzWnqJFWNwNutmhWmyYmRR5/jPY3N2y0NGxuzK43CMpQQ6dow6iyCWK8smZJyFp0OJstP51T9t1lx8MZ4upZ5wOH/wQgrMTlO8VGM9gX3CWjXOTfVpbYv+RaoyuLNLtuhtpiEb7j5Gqn0GUOIdaR8NGlqFqYPU7h4muN74POsxqKgpDpjtFe+cO1Cpt8phTtO4eA3x+jel2QfpEbQrjx3JzTdV+EBxEtzNZES6uzh5KCBQwuv0FjAOUsRhXTghihGWLfa3mk9YhoKRvwBfu1OpTg1quL+2lVkB4TjWczfcREGGyYXf8Kobnj9EOtp3aj6CwEQSltZ+afEOxkAa88HTkXho6P23rUwcOD9+5FXlmAl2rTTpcmtZOVWBnUKQS6v2Rz64SNSwNaJ1Y+1B7iTz9HfN6UhJBeCc2UZe2uB4kH9iwi5hVHvKZb+6eW6oQlyqyP/R4TQk8TJikoQFAOsCfDdx5pfrAmh7gqZ1qtaK6iz+jkxBp/FADevgs3rMXt+6HOau/wG7cO4Yvd9f+vMEZ7rBUui7ULPG/t0dxXILBlLKwsCAwEAAQ=="

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
  password = "P@$$w0rd6286!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042919495028"
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
