
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074205489509"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230519074205489509"
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
  name                = "acctestpip-230519074205489509"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230519074205489509"
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
  name                            = "acctestVM-230519074205489509"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1800!"
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
  name                         = "acctest-akcc-230519074205489509"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA9DGO4iPTYftJWV2l6uAvf69hY7KqRX7w22ZN5IsFMwA0BP1gAzMaxLibXGFHyyxvjbK+F2h90+qxlA1uAR8fIbFtOgwUJxwa62AVkAQwOd0FHraiT5GDNAre78MIXXDG7fPl2hbRKTdbejVhzdxiJszig6t8xx3p5LX69H6REhNiXE6BqG0iao7vnCowsxH9ZzaqUAyuQqJeqIIbWoXzoZ/KaZhykIrxvDQaa3dP++YwV19jdLDsqLHaQgVHcIslripvgqBK4qxDtXRnmdo10ORFnwXelYsex2CZiFyKSdM7kerHBv+1g0U0JIEX/MXweOuytZ4aJGyC6eOfgtipSKz2QpXXUZh6tjDo7mn4ThlsLZz6KMQqTpwdumFTp0X5iitimog2jsi1kNMnwltgcD5Rzbjgp6uetYXn+aunSwY5wqKqdZYQeA6jnxMIML7fTkCwi6J6CL7xtqSRbubLrhWEgUFRnvToNlv3Td6Xyj7SqVMtph0Qj3ZQiWnJ61x8oM6OyBJ0tMb3tByLcRaN37iLVELfXa9t8s0Vu51jotu+7zgqKJ9ccpbNjszEZ7oEsmFDgALvA8PDjeaIN1F+weFPhjibRuhGNZ5Rd9O7eA9iOtv0JegGFFLW+gBMAo7xMH9Vp6vhYnZdmVrFezQkjv7k2JWobWfi9GEk3ZChyTECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1800!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230519074205489509"
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
