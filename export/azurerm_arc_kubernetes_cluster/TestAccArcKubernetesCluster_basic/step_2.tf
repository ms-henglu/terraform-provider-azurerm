
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023515520990"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023515520990"
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
  name                = "acctestpip-230818023515520990"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023515520990"
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
  name                            = "acctestVM-230818023515520990"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7440!"
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
  name                         = "acctest-akcc-230818023515520990"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAlFfWOUosOI3UkNm0k/LbSGxAs6AJSuHyoeEcMQGKj3CEzWdETjNHRJBOIpsunRz8CFS4hBm3QRArkLPYvWR96HZIG5Gcz0cXiU7aBmNprUH09m5rrLu+xZepKtkyZBDzkHomAU44uS4HfLsxVyqRkXsnmSuUu/nMot6k1Ix/1DiI2bdkXIcXvxdMWq89dPT1+r/5RwURKXsqZv8ptzKTo7jhy21w3ABH6VM7LisjFrNoxV7TiFft3571Dq39pUzd2vx7ODihDIlYvnuWqX8UmBjwUxcY6skMDrOKt+lwrVUDZTy2adregSr4QUZT/LFFEjuOiTFtdoJnIwMWYIC1RsaUeFLcH2/IzgwSJwgVXMeEoqYNtNBFLbjhk0Tl1n+vtx9wsW5kABUsIY0NRJLHVKwEjRgQ24AlH5tvO9xXALuWAGSNii/9o3nlY8qZlpSno7tBbSMS5cnCvOx11evvgUj+c91HtI+mCFPbj8JVRJix1+NRx2z4jFep8Ss/sZdSkZMRoN5/BMMp6ollHhgjI3r5vvhyKkw5Vgf+Ve9aCn5mJg7VVfRBLNYDfiXzIcjmLe/idbp6nWD6Bwr4tvKKrq4EPRxreuJRsni+S/kOXq0kmOao6NoykDzBridk5CFtIsNDNApojRsTCAtFTE1RF1NHqYGiYdfsZpIX/KWKVz0CAwEAAQ=="

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
  password = "P@$$w0rd7440!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023515520990"
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
