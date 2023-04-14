
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414020743343211"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230414020743343211"
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
  name                = "acctestpip-230414020743343211"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230414020743343211"
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
  name                            = "acctestVM-230414020743343211"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8114!"
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
  name                         = "acctest-akcc-230414020743343211"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtoTcCAgUHzrlNNsJNyfzBZsWAIebWHHahmb0qyhZmEddF1RFr9FrAb8kUMwuZAIM78KRu+w9BtqBVRXjH2NGM+HsbJjUHVMqqprIoa81ilZF+BsZliYEG0ATFwV7BGiRM3/M4Wj9sGzxfbB/Ai2Hk+PujBgmwAGLgdDY+0EOko9ihK2+bXlcUCryXhbx9xmpJxFHathcS9aPi1ZOdA/sCoetGSLrp6dc0Ut4Mjsi5JX+EkpSbvO2Ujzesix5bbA/qx1GAg0LAQQqITJYm6TXO+w0PeHWJRhMRgVli/J55K3URVMiVceqNylw2j4A7W4eNXTLyD9ptwgX6axagDPUf4TKlkmdP/YTh3q7LmaW+ho8GBGy/x7l/0lqjGvYGyWRWPLAxz2sw462C18tJcRtjZI58NfY1RZT7dfUbdMTp1W8Ijy6z+dVyZcm/IbIZC8wUq+0ozNttFElzZHfVqct0HiTSPYq/mYWU+JrluMKIRbbZvgW5qaGNJXM1+w4rcjQeDnR7bmD8mkKouuSdtNf/sXYsS/HTkSBeoCTCu19VNWz0jovJUdgvfMosdFGGbIO19pUVcyA/mGAFMp2OeAelTj+KvB5vx5nLrLYPNk2D9NawYJflK2oI96eaUoBX/NLXcY5WLDlyDQgxaOiLu4YGKFsJufbwb/ezus5O3Gswr0CAwEAAQ=="

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
  password = "P@$$w0rd8114!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230414020743343211"
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
