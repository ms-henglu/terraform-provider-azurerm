

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025033030205"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025033030205"
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
  name                = "acctestpip-230728025033030205"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025033030205"
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
  name                            = "acctestVM-230728025033030205"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9038!"
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
  name                         = "acctest-akcc-230728025033030205"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtrZlASytN86Xn4xqr1apEe+wv9AgkRPIdNFN0kVi6oIKtXQSx95qtuvoZ9iL2ZR9kIv0BNMN4tHhuGzoQNnejgoO+uavubhGixP7L6rIUnfUMzThtV0Tc9toaoDJAx3dmeiMUj8D5o99K0UKjdaMtdIJEXkOOCWFXupbmLeQAKQ+HsQoQhwuP5MNC5kmjtcq0lcXk8M5V5RnfdmqPBbU+nYkAV2v3oZWbDVhFjpMlBHwwbk7ZbchXadKd7dWDlynoEu+I4+TN4M+PRKz/fdpmpdUwUOnhgm/hk6jiIu9aasjwxf0o539bvNhWxPKBnV6iDFZR4tYWheJ43K0H3QX7jL22Bzo+GeSN95vHyFR3quBy0ol70A/Z3QmeCH7t0scb9Rq5E5YI4f0aIylOqfXHrinGv9dZuY6/ycwdu1u+paEoZki5fmtG/HcN8YkRGu+hFvVQwp1DyZD65MFVzVPBiKLn35CMVaJ1sSgybdB9b6FC6yoFHYHXIRK+EKXj3mOJBnqn6aIo3/JSK3CpAptGX5+S0pOZC0Isc16fzL2sSNZ+gp+BYluWc3lCInOy1bkmp1TOY6h5ReqBh7wal0+gfhyOu9LzVnFtRQHUIQyjvoeR8FO5sQWNmGdqhVWfThNAgVlIgEshkj+Qw/ESJto3mdW7waY1O+SvfWP+NFSAzkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9038!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025033030205"
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
0kROJQKCAQEAuDGPc0sFY/AbKZWblapnTSnKwpx2TyUcni4hKO+BKHvOIPdXrtUT
8EJvTy6OWT1UHFSY5vczE3SdHx7pZA4yySSObkXtWzfZTRpcjBUtYuPx8Gs7gDHI
otHj+3gzxJj/PVzINt2GUIXSCLEU/DhWAVVxN3GTBuzVhkW3GA6huCzDwg1K0iCN
BUN3t2OAzVZL6Os/tzCOd3mL3hI5oowbNmMBjWzpoTeZfNFR2g/5/yTA2mLbZp5z
qqdoKuip0ka+FTpU/KySGRDKuSPHXv+FXSJyE3GuoyyeMnL1fUXOItqQ83VRGS5I
uI4qRAT1xTsTafwrQtAHUwWQ3MtFS1N7cQKCAQBk586VcUkekrfVm3+Fkr6hjoAr
BwtswJLA4yYEjwMv6831FXope0uYwANXd7QL+5NYX+igh0b/GxtKnLHkXx8jLN57
C2+Pe1tWznuBXQunSMK6OvsfP+jbM8NT7pkRDlsvBMnlVOoa09L2917S/v0Gx7dJ
9+mW+DwAxKkoAw4cy/KD4Y47pkkogela0fUqcvYgUUTzVX1JmsEx+mt/z8VUlw4y
9yr5DsnHtNXP10lzMnkkXhq7TYb6s6LBiV+6QgMpLdtl/kIjKfBAjV2ajRZsV6JA
VrO6zcn59P9CdkwqPkDs2wL1OIrOxc0VYETlI65hXWt2vu7FWoo9fn0i03t/
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


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-230728025033030205"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
