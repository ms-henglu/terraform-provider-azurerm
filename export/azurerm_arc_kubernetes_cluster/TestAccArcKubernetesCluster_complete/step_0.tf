
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142941323257"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142941323257"
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
  name                = "acctestpip-230810142941323257"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142941323257"
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
  name                            = "acctestVM-230810142941323257"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8961!"
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
  name                         = "acctest-akcc-230810142941323257"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAx+5jz6Vr/UKJ5475QZuba4ovQMfLcGuh+j43AY4tyG6kIvJoN9dVKzkgTmpDVA4uOBhEEUQFQl8hgTm7FIhttbnzv0N4KRLWBv3UWGS/z3Ayw7i3kbjUVkcnJMu+DUgLXFb2EuUwNU55Xub/PKIV6LTnn4SCN6moTs5l1tctU1SYOG+NyGFmkx2Ks5LYu6iEnSePlRooIm6XWx8Oopsf9gagrnCru+viNUco0hovlKVE3QGE+yjbcY72NlKHy422cGgi8sF0Rmw1rYh97jqCS8LECYZMDicQddGUA7tmd+K0gTgnykt5eIrZq/bqs8WWGIr+lKwTc4FRCg/tW+CEn346Avu0n/eXCzFNxNNx2VuOXrqRqOHXUYNMVkozWZ/Kp9s31I/AQwRyuJ4jBnERzHEo/pOVUQKOPBMwcKUAO1nu1KrXYv0NXiZz398niwdorK0lV32ia06mSZEpk6xv/+26R8kxOP63NGCn7BqWYVyRbXtuZs7TYuH+dFlTVaVdGEwC2HlkY95t9nZY91tuP7dN613Jpodq3I/wBQwY+GyQmQOurZdBtjp/md8dHxCX1TzcWeP+KpS8vLX2FhZLUTlk9U1CjMrRI+Z0sZ3LQTYGJ4wIa4il/W7zXQ4fo4ZkMS91rUdjiW34iimcdI0oQ5u+kvqrZ8SLNFxT6oYQ6ykCAwEAAQ=="

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
  password = "P@$$w0rd8961!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142941323257"
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
