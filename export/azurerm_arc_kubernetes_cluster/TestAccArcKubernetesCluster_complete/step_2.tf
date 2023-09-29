
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064351402983"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064351402983"
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
  name                = "acctestpip-230929064351402983"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064351402983"
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
  name                            = "acctestVM-230929064351402983"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2187!"
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
  name                         = "acctest-akcc-230929064351402983"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2WiH0yuJoqI/dI3BQvWw+N8XBkUv6gZpwiWkLmgekEDSXKtYHP7gxktSF6IrOCLPml66jg+tzcOprAJE9c9+zS2Vzx8yQjo0Xvmhy1l3IhhJYXsbhegQyRJl0OiIkIsW08Kxr8hzKAISOG5sGwAFjJQ0Xm/9KKDOZdZxhQr6NaFqZzoqBArvZHXsZXI+TAlCgvaNELfnC2WW6Y/fKa0Q2ZjyYnk92vEWyVLH/I9Mbirp4ecTjHpsMczqftGDnd7fRPyH73r/qoPOcbKcM2yHcOnn9QzgGKbICCCeN6yWMQIn/Qe5waz21bqgY+jDf6OVRjgOThr+MrPmhxp3c/iWSrUruOx0b0K6EkdM3tuln6Ta7VTaY/lNrrwkrt2GyPfTxp50Ne7TmAdmqQJYDOXCj6NbiR6IQp2x0Kbe54K44bbt1kYeiZm08Fo6945z7JfEJIlC+owa7LzztU31FvMW3bUS5v+4qFk+vlEDydxE9ARErK/BIgu44EKp9UQCrQTyX5/amkAwdJBNqfxMBGVkP0v+Aaj7iP8uDeOv2/0ac9FS1Vnih5maflXSa8TW6YcFFQan2e/ZR+jK5m8R3NdkAIdlmKAuqn3armvvKZ6G5y4RNo4xbLxQ6sykT9vG5OHqX11XyQ5thKwd+mHFwD3iHvcpv5sod5o40W0ZKFfy7AsCAwEAAQ=="

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
  password = "P@$$w0rd2187!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064351402983"
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
