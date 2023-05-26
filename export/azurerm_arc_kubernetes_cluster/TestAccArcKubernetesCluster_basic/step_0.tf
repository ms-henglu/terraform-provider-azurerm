
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526084609653628"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230526084609653628"
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
  name                = "acctestpip-230526084609653628"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230526084609653628"
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
  name                            = "acctestVM-230526084609653628"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7684!"
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
  name                         = "acctest-akcc-230526084609653628"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA6t6Q9ch2mUrRIkHIbxA09rYGpip6co5iIIuXU9MBDpF3c1+IFNlsAYmlYUiOqw5fASVZ248N9pYoFe2JXWvSb5FUqTCKgH3RjVyJIheW7G6wiHH7hqsWQxg5VQO612b9Hk1PBWunPETSxqRI/Vyr3tVjCbR8b27RLNGc2AIpaQatqwb5BMo8Oa5UmwptsbGF8f3wxTbBoNMq1zxxdtTM5NDrE7XbjrMb8MfKjl/mYPuRRbIjkPEV2CjxXoegyzsuhBpjjUNYcPEvNzQa8Owsr+7gEv166rk6F+f5Jk1San2G8kFKp/Po5TbEh/vMIt5/a+MO+mH43Vi1aSff93W1J5JDPfbPp6kAg0a9E3zGINKYDzmw/71hUUYI5f5GCIozaIh73IKjl2faHg8oli6d2GT0RX6IAZcWLGQwuxPFCBHxrHOfvdKYE4Q7GmNyk6+pP4LaNq7cAbG8d690Nmu7FAzZXjQ8H9mwHcZ7b+dloo2JkZBb7LNEOW/Py51TXnZf9hWJXQpe05VE08rr2qLlYKzRaEQ/Ln1fFr5D+LcD+5CKkzh3PaAwwqFc2Xhv3bkfT8Y2Hr+EjL/VZRiQMzOsvJaeTthRzqjGqF3b0OpbFAPtwAS1SEnfWz6iDJPcFAObmFhwXOBjlXs0VToL/SHGFgpNWe/sWdV0rYalgq1gJoECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7684!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230526084609653628"
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
