

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032641017059"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032641017059"
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
  name                = "acctestpip-230630032641017059"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032641017059"
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
  name                            = "acctestVM-230630032641017059"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3504!"
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
  name                         = "acctest-akcc-230630032641017059"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyMIWlaomy3JfwSCA6AKTzpERd4W64saGJkfArdZioqZJSlMxQf/KDzyMGe1cHBX2vUwD+vFlvqZcAJSHDJe9al5Af14kd3qxVDZoYEgFniCZWxnVDqgQ/eREppJmqaCyPOMuw9p4A9d0Zb+vgGV3o3WbsMTY8UjDwlQ32wIPyf0XgNRSfenJO08s1jxKdLhaSO53FtFKPDTBR8o8DcoiJ6n1EJUli7paviSDgpugXuZ56dTlfBQM8wEytB3SvcsmlU9dE8dDrOqI//t13ORiflPRQhEjUQ/xrQp7ubqgIRsphy2N2t7j3FaOoI3EFMyjA8iUe3LbfXhiCFJ4Ls8KCU8D9O6w8kk7L6sQoPByfc3PBjZEZB2k8nC8Qv02hcSwW2KZOc7fyk2h0Ri9tfKwVGF8LXkEyP3XWeTwdu5y6n9cbVL0X1NFFdii54TWq8xN3ZqRCtk7HoNC97WYvi4QyN3XNCN4VUcNmDjV9uJCyX6DjkKmzTLjec+NJDxj+aZVkSGFMf3831H2jWaBRM9zqLcvNSp+UJ1LLqbNJfQIodZ9UulOZprqR1tT6VYRb6SgBWK4qn7tQvh1EcpAbFI+DrE8PYNbXMnoXuBpCWDCZBdLAbIdLKqOKMb6kS2Ai527HOxuqTwuaR4ql6nqgB46dr7MFa6ekjoqBtKKQUkhOpkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3504!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032641017059"
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


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-230630032641017059"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
