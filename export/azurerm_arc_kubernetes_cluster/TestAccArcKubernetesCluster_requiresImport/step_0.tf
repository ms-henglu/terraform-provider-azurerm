
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063252968278"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063252968278"
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
  name                = "acctestpip-240105063252968278"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063252968278"
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
  name                            = "acctestVM-240105063252968278"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8157!"
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
  name                         = "acctest-akcc-240105063252968278"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA24rlfgVApDqJaz2YapZAQVpcD5EOd7V0MJXOCGvfTU0/LslwMf4JDcw8Rl/Pt1htiT7B5d0pPn77ijjeof/3D9LT3B5QGTgl3AbbQV9wgQ+0hcdgeWhU59zJxvziHvAUEl84uRgsQFDdsq/5bwyEKehkiM/YuHDCCQy0SsF6i0LpEykXNk3bLJEM5RXvfZOCtWNbTu1IRLTdYZaiN9C2hK/wCUtJzLpULc7iEpW5CMaNApBS10W9zK0VJ5QQ50jhzoIgMTvbmFQSTdkKeMjOyNOU7bGuUst8f3lRVrhz7hj+axNlNUYDeUkQ3D3UOros7RXqWbfkWeAQL9j16pAuwQwYPftf5uNYJ/XYEUsFTAs9cv2VN9Degy3Wg8wU6Lx4cJeb7kZ0/rNON/Co4ecQfV/AnJOtB8N2sHMgs0oxB6d7z0LyW3dxK4wYdwDCBeigWsafb70f9QtxH+CY+/mfYyE5PpDgu8dXwJIQLoo0sRatW8hPpBKUjSkpWFMmKuQUnmGJmnZ2/mLFaWps4Lh9t73OrBvn+v9f7uEO9Xa+C898T02LYFblLfQpc3dCd6mjqJpween0Vgby0B6JgE1RYMnPL5WmEOzpBR2Hk8xzI0qJQ0LrQOeMfHYG0lcJGfZwFEGW9e2yGZPRsPPRsFgIArk2+3obf73V71HYvha4BxMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8157!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063252968278"
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
