
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045225390798"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230428045225390798"
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
  name                = "acctestpip-230428045225390798"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230428045225390798"
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
  name                            = "acctestVM-230428045225390798"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1323!"
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
  name                         = "acctest-akcc-230428045225390798"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2eixy7MK2hMKA5NadUoeOgsTQGgPJZd9rilLX7iMfBJYVPqIK/EG/aIHyBrtCXu1Kae+LfkZgsopqgxFwenxUIcfVIINhQ9fXMIsIIkzos/MoCVo33PY+bkj6cuVOJMEk5k84EmiKeD2feQ4a3ecmLGxNA0RaTvUumBtgmjesM+pgeuyLDE4o+u8AK9zW2xd++XdtFKE/f7QxVvMbgoBmoE4bFvQ3JwBoXQg0Vbd2I0Qa+JK5uD556pBPXC0Enq6sSLD+O70cVECsNBLQW7iNa0H+XVoePaQhBU9xwuMrWhggMxlgerSqhWmizVyLYpuZe3CqG7d3sZVzzlaAni/Qq8NKo/+76m2BAHMr1VH+9SRrNRpNP+EMqesMK+r7X6jVR62rH7NXRsiSw7anqrZxLkuYq+XyRPZrFDGJuzN0MAPeI6uCzoi4sFuBHutsfItirsc9z08n3yC34EuV/8ayoQ0R4Hje5dGgTn+bPeDlLoQJLP2InMb4Q41VTVA8Ut7hjfjpZCLQuPjRGUZclif4Y3MdlDQ9AvtSeUimFc81nJZZdv/mOp8OFr+hUvU99MiO9mO1jEYfEteyoVDL+FPyUyzqCNKuIg0gqwLIKXeScGi9rtGR8Zi78SY3I7aNctTGUte0BPEMFimj5gmRJ9IHZXVh/zeaJLOX1BFFKKevaECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1323!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230428045225390798"
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
