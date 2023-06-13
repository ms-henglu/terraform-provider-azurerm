
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071338114982"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071338114982"
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
  name                = "acctestpip-230613071338114982"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071338114982"
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
  name                            = "acctestVM-230613071338114982"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9226!"
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
  name                         = "acctest-akcc-230613071338114982"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxkwXnE+Nfu+KR2W+ebSa/QVPOrmxt3zUQAhIA4Raglb1cYCf+zdWxM47zeLgAcSEv6CNzXMw193IHXYPm5nOMRznveXRXCNZ75rdXe/MxLBBqtuLO621gyTkG1SsD/JBgKRSyxF/11o+AeGFvdp/xkZZx8Ulp/96mFp/Am9QPAvB6oB7ZddFlYFRuYUbZJ6PnRVFY1zDW171nkBnd3+YxPsVji7LVuQiDvQX4sYQ+vBvnSd+pW7ENDKgOGSY5KVZk4DnpGNmhTultsAAr2U1n0dMUlSG3Gf4A+I/ZNq+/lqmBxM4jszJXd3buOmOH0TidRVRRmWe2H/jbLQ7aZdW6bVjgqSTwqcV1OZpjmHHnsfA1f9VGIrzNf79A2JLHcnoDJ3/qmiqW5lKQpcOmY2OlmP8vghB1mJN5J97V6pMsOU9LQFwh6/aPCCu/4ytmP2yGB0r0K3lzCyLvSvw4kFZNlR89BjshbwtmaqNTk135h1G57lYeNFal+N+AL18uOMg5fUhUtpz7wJMvdWVc1FfHQ6NTeSvPsCVFyR2RryZXfLkGtwKNghh2G6qIhxL/5S42jimPFpHvastb3zRcxwXMnPJqGiR3Qekq9U8n4tm7TgX9qKyw+CCsrzN9e3h7wWsQ6yauN9fMZXQBW8egFeY2B3/HbSXAAUJMLskhbmJNd8CAwEAAQ=="

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
  password = "P@$$w0rd9226!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071338114982"
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
