
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063251627567"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063251627567"
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
  name                = "acctestpip-240105063251627567"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063251627567"
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
  name                            = "acctestVM-240105063251627567"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5826!"
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
  name                         = "acctest-akcc-240105063251627567"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqZuBJVCsLQLPVYnE9UYi/ufZrMaKOJW49i33dsgl/saPUnYUvKBMhdtdknJPBDjgwynWMxrkPttj/w6gfu0U0+CsxtV0iwr2hxVR54UICf3hht094gArlBba84mUb/eR4KSaPzfF3Z/uqlqGfh+RAz437ZJ/VRNObp2usUZTWWXA2Q1o0vX03W0R2p+5vhuoYTurOcaZUfm+AXvG3MiYgcwuQuXTpyHffilbXADmzto7CagfAj0QeeprspMDakXrwgSTVcZ8PPlr4IuCxnzpBVtuSRiclHiV7tFrCEv1uu8d0uqjeIzVg/QYTKGcyleBnjKqjolEDftrX/YAZ22S2+3nk7Fmimg6g3ABHb2eSFqj8+iqrC/+WJv8LhDvnvywp7chLncyT2MV8KT9aWid0c3KEPPgEu7ZWff4dBoaRCzE74A1kej/73162SXr9VTz4suhFtKLPgWbPrMjJ9bjLQjgeDyM8MyL47FVtcQn/Ic2IY3TBOBm2BwOCZ2T8DyaNqwx8bAn3MTStTwqmNWe1CLfmlUBg6M2DwebDiEEP5nPJAkSf3tCalPoaT5CUUu7H/qk8Sgmvt4kBUlhKnyj1Pd1usDA8XiAbH0aC6B3+LK9y2DFmyIfuAUmZBOv9NOjYMAzAopLZUjWXqmUgETI5XkeJvLvj2LYZcuCC0Gq7SECAwEAAQ=="

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
  password = "P@$$w0rd5826!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063251627567"
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
