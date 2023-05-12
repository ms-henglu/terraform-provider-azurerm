
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003434394026"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512003434394026"
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
  name                = "acctestpip-230512003434394026"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512003434394026"
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
  name                            = "acctestVM-230512003434394026"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1117!"
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
  name                         = "acctest-akcc-230512003434394026"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3vPBktgBe5RJjNPV7O2r4eqNsa+HHISxgFFRo15TKbQl1IGfNbzPoUOzsm/F2bFtvOzgwpp+ojLzPAkwoau4hsBdmE381Z5EAZ+WrKRJeRR3JWfjQRTNWevAATR20P6yrffn5eMMemjaSHTr1F9Y3D0cqlSOUImhxd5N6gER7tCxrfovQDxR6W1GiBTZkEcoO/Os1Od0c9R7mJo3dcHX0HrLgLweFhSKsAWk/SrxTiy2bdlmUwdoSQ8yehO/LnyRwnExuGDzmO+P0BLyjfjkmFY5CwDLF0jN0sYcbnulWJozlgVDi0C1MSZEzCCl7hOUo83Qgvigs3o/mRRaYpBx6rdYvRFpGkxxY0th7YWC5A4NWubvGm5vduqYAtgZXIsL9DW1oE3Y8VHPANTQaEBNBtxhAeMN3sVm8BV8MObHanVCqtUuM1pYy+F9MHRwMg5haZvOjU7ahg5I0V3p0euB9AXPMXZMchzCfZ09e3FDUaILd+a1DNr50fEhPxEnpq8XJONt6+NrkGEm+4dbVSGx/3/hiktXzjaNw5reIB00KhnYdBgkb/HSr4axZWZQL4ffV0c0BMhkCnLhmGAhSmzWQAovI792c2RxCUdRVBToSHqLFjYoscZUtQPEFgHREWizh3EUoZ2p0Ge11chCQD2B00gTWDih9iERqq8GyesPPmcCAwEAAQ=="

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
  password = "P@$$w0rd1117!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512003434394026"
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
