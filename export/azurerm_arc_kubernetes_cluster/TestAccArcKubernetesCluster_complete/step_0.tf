
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025052206276"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025052206276"
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
  name                = "acctestpip-230728025052206276"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025052206276"
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
  name                            = "acctestVM-230728025052206276"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4573!"
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
  name                         = "acctest-akcc-230728025052206276"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwupY4F16otRK94OyTir/Sf/V1alO28KV1GAOEu8ufCvb9rxDOvsglR135+tCuul/xy+5J4ke+IE5F7nteZVBkenLD0XXH9cjDmkr/mgwvbBPDlYRE+WoiWItBCrjlutnA67FRuyVeUlfjruTWwTaD1Z7DieWL6O6PEeoFYjiRLmK2KrhOZrcUoY4biXP+b49nq61kxY6TdbJFyaaJF4Gn1eUuAMJrWcJm9s4xklzrKuxBVSoYl+WTsBzcNDH7csLzjRbZ3mfgWAC7jkK6QNUMmjAwqFUFAAiaWwjPzwkjKLwa3FZ36XhXbNpmMLzZmGnYTrQDxYHeGqfdmwWkwW/CrowKB6GlePMt6TwwshV3SbLfaO2affUwHkmrRmjJbfPag8tRQXz4UaqY3WjpIubFNdluTW/vH0ZO4b8DLDYpiuE4NPQSOrDR2UiLfVr37Lb/+0e0+Gy5LgxfIO+O01cZmu7MlajBQ9x4y1NXUZUAQot0JH4YKSCa8KRVVOX/XVrVj1mZbV6NAmACXzKECv9HipLH9P2myapb+or9C30FeTYcDHn+LI/KL6dLxomRo0V/r+O2pwQs1v31L0/pU3HoYoq89lUtYdKF4MYoDBwPZFe1xDhrksl7KP53LLyNmajSON697AKYFAFV1z4rmk2Mir+Rf/NnWQdIoY+aGTBnakCAwEAAQ=="

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
  password = "P@$$w0rd4573!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025052206276"
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
