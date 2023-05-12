
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010221470933"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512010221470933"
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
  name                = "acctestpip-230512010221470933"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512010221470933"
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
  name                            = "acctestVM-230512010221470933"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5231!"
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
  name                         = "acctest-akcc-230512010221470933"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA8bOvbhMvbkfgXbtj96v179sUU/XhFdhNx8jtBqJUCZF0gJ2tcNNHV8eY9MghCTrFYo1D785BF3+l1nbcdteYcp11HefIgc4WD3Yv6jlfhXOZ1BSdnLQcJHyjMcsT/PcOKhZfscfh+M0cTXOxR+/jmSXRIM8MvuC4aVvc9IQ8TDihsmAGiOEdA3GIey9eu8BVZRlD6gMuZjs3SEbF59o4Nde3+VIl+VAsohliYWYuRZm2WPq7y3pyp7leutOIPpmx3v7knO4Sboosw4UJSAeO1LsTE0ggnvqmcIPVnVzqF2S22OXpvrOOb4MLonBW2GQ6ts6D+XD93tM65A0m00mThYWvywa+8TMn9kI4Vor0rmQuB859HNklP7f0avpO6teAHbVnW4iXhuMCLuTXsZs6eWGUQeKnoU2Io19bHU8zkaNpPGJhpEKhfr2eZrwgk2/Vr6U0G4xxkY+SCx5RYsE0ssKABbfCkWL7+pFSfFO96NVreIsaBbMeBQGGDEL3HlNTuygY1P2pehO6DZhcbUBM+dB5/wZtpmNJdI0ELkHkLZKA0qZPhJdR3wBxIU6ZJU5gM+P3SsMAbefJUPtkyv6V++Pgic6loYyuOfQwNT3Oz4k0c0AV4hUH1ZfeDJpxnxjOAUfaIuZpn5KATmB33l+0pO8Y7DSMDc7NLKu8/QabvJECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5231!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512010221470933"
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


resource "azurerm_arc_kubernetes_cluster" "import" {
  name                         = azurerm_arc_kubernetes_cluster.test.name
  resource_group_name          = azurerm_arc_kubernetes_cluster.test.resource_group_name
  location                     = azurerm_arc_kubernetes_cluster.test.location
  agent_public_key_certificate = azurerm_arc_kubernetes_cluster.test.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }
}
