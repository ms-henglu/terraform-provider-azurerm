
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071335651219"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071335651219"
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
  name                = "acctestpip-230613071335651219"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071335651219"
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
  name                            = "acctestVM-230613071335651219"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2078!"
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
  name                         = "acctest-akcc-230613071335651219"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxQ6sYYVWGj3aADo0W2Y2GKlYpIqw8jgoHSqaE84nR5uCteN/yTbCbNwpXHA+Q+KDSB6GEiaSxuNb1bvwfD2Rc4G3WfJIIKFmYrGD/KDTpyz4HcD1MFTlOiI+utgGkwVtmrsOtLN27XtQX9x2hHqI34WDlTG2eQeLU2JJHmNrdSfFrGucmTp2eM7adyu/4QRn8Ma/1gZLmFoLMPzDVC/s8EualH1OkJ9r7PSUERpo8W+Blqm3F8mdyexg0NGKsiksJMBAAzUx9GshKKeOkofsVZottHAjhFcDkgrF/qEtzgI/P92MU3BN/jfZXeNzsrZIkSTG4EKV63NOlzB+aSP8krL9VuuZ2Fj+4+A/b0aABaARweY5hF5dcu0t8QIvw5Ep5unpDSr6jprd1u1gV06mjiG+OyufLgI0enOT5FE0Ggi7RF7WohpFH5H7GuUFVkfH9dyjS1y9mUaAfnuES9chYZ7JCcaW2SqC2ljLTNhVl9E0FOcfkyC9Ib/dVxH/UkxeLE62UJfPDPDNN6tVbwiIL05K93dGe9xGNfjWWuRwyA1VClmoU4ckCku7Lc1roaUB6dYgfD2C3TA4+XN4hT3Hr10aZ8ctX8Yug8eJm34qsZbTWy01y33zTjVbXUkdSbBqv8hMMvVLUOsHMN22681jmWKRbmKW+ZnvATafxEzxL2sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2078!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071335651219"
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
