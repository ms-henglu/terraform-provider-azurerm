
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421021654683734"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230421021654683734"
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
  name                = "acctestpip-230421021654683734"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230421021654683734"
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
  name                            = "acctestVM-230421021654683734"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5068!"
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
  name                         = "acctest-akcc-230421021654683734"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3FRT/xNI7DxchhaayAqdaJRTzGhUO+JUJG5FDpq0EVDtihAPiaF2ZviH2bxdSH5NS+6uDqt2nmPZSw2jwiu7NrT8YF1g5Q/LGAyP7zhNeOcvWsSMNlrzNcYTvs5sWtiWsAPHaRPayXwBbejmrygJzrmzS945LYmt237unDzwSc+mEW6NHn6Ek4c6iDLhvJQVDXfWf3yGOOYZoj4KjazVeAHOZrNfEqMi5NlQqInOZEwTGk6vq03ENusNWwP5RKF0jhMtZT9SGWEmef9VoQ4UG+66NJHT8kUlmZgsv5iV58a5KZ8AF8QFTwyVRtA0BJWBmyEhPRWNUpNMpeC+trDcBs7zLX6LEXknZk+uWiPUywSrHybf/SV6XwOrBLA4lREnAQP5CgZ7SVaz+qp2aDPNcFCV+4FbrbBg2bvpj77yJnrqLIvEXnqpiY8LVKh/rnFgNE5EJ/nMAXnpGm/vBQ4KwQl+RXJLxCoutHQF6yMLE9pm3r52mV08vD+0chH5jteKNgTN26K+Yk+uMdMqoiknw0/iDjIsp4nmCjV0DESCQyK/Wf50kNW8YJdnwgLpzhfja9NfLaXWNDYEJJkx+ITfxFLypHiKsJ07geirWynRcmjvdhR+yIAAke01rz5zeEhzpkEcQVilz5Q/1wpfByg5xFhl89IiJsSpFqak6iel1T8CAwEAAQ=="

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
  password = "P@$$w0rd5068!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230421021654683734"
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
