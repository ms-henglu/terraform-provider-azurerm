
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142937892154"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142937892154"
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
  name                = "acctestpip-230810142937892154"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142937892154"
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
  name                            = "acctestVM-230810142937892154"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1905!"
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
  name                         = "acctest-akcc-230810142937892154"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAlpSyqZKjccfoBWCEyFvcu4tjQBFIFCLpJh5M36d4frmKAz66MtEyvdhh1hQAOYgIMvFj74pLudN7dxGH1wnRMC8BYXvczkXc4ckWoxSiuTRL01yTWEB9cthINbZU7wj3yBg0vSDYv6AoDtVjmsSkcjw35j7SWcXbew98wTimqozDJVYiE7NJibRqfY+BcVFQzAwEgIinwhDQnOd4KiAczQJ+DFPIWU0PTpPMfukr4oRRhIbu83WUAYg7XJ+e542unp63WN2sm3mNFQQRQLbaM9WiHp8NRSQseCgtc3EABGCL0A0FKKF3phByuU2o6guHAPMT9NWmRYplQtyUbcHyJMAhrtd7O49hOtunLqWey0FsXgbtww1XwMrAzF+w7p6JDaxq0xdCz6z0ftY1MAxBr4Bm73KqGi10PDdpWLhB7L82Mn15bp3WAX+ctVYvgUMM6FWLQ9ZK5rgWBMkILmDnH6vsHs5y/Tn3JDb3KeUKKJgzY4r18GH+zvmRP/TDGlwUOnBJoqs/FT7FGzRGv/LLJs1oSa2sHsBfxmRrMseTvWhm0YwMFpybqQrCKeVx89L7dJR0R/jb+95hAJlrUGTVvgD6Vb898SI3b+XYB5Si+QXm0iMPuWYygHdOjT8eqQxzJCSbh3htEnzW+IoXXFMc7msX0SpXC6z5gHhquKkfE2ECAwEAAQ=="

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
  password = "P@$$w0rd1905!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142937892154"
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
