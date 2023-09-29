
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064350494371"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064350494371"
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
  name                = "acctestpip-230929064350494371"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064350494371"
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
  name                            = "acctestVM-230929064350494371"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4258!"
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
  name                         = "acctest-akcc-230929064350494371"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApSeZFKl8OrDoneKab1fA9DLVfYylNWiYT9m4Qr/WNbVtVZSHDMZlEtCwIcuSkLJsc+I1vCA7UgraVcofawGJgwhrsM0HWyaJbUdBgN5QW7e+9Df6aYKaqV2NiT82p+OQ2VEAG1Z2S1tbaP3xUUO5WXdX3lE8pWoVDMRolqrZ0Z4HgJdBT0jMj6BDNQ95W5ApqQOfdK9dOJVwp7gDKXbTgY9kZqfjz64fUS8cN7Ihf8NxmBXBFplhI5UnOOqkS99UJVo8RZ2gxe2cs67MojciCup/mU1+ewi4Wm18TZuQuIJVzNbhqsh4Xebz6O487iEXSE6QClaRbFMV45TVD0oVb2HBnuH+87Jt18p6LOeE/sUNcwsDS8ynLInsPudJn+JRu+dEFKgx6nPqkz6tBOrcjxFnFYyl6M82/uohticNAXM/O5LtDLSrkpCAiN8aVSIj2NcbJFnA7gPN9HQBzPH8PDW2ZIJP+hRN1GMIWL8haVXBfjIJMvLtWrpdObY7MgwSG28LqKFCGRbZmaZmT0YoZyeXBM5pz4jD48kVRI7sasp3DoQvbL/FsccqLxZQT51eTYyPMgFWONfLY3j5dtpu7oNKgerrcSYAPmzW57oJU26E6RLgAxuJWMCFsy/c0nhuNo0tcwGlG8ze/WsR5sBGVEKkWfpk6BQuUivKing140sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4258!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064350494371"
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
