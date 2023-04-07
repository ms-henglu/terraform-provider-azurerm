
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407022916561466"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230407022916561466"
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
  name                = "acctestpip-230407022916561466"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230407022916561466"
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
  name                            = "acctestVM-230407022916561466"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8913!"
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
  name                         = "acctest-akcc-230407022916561466"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2R81Fcw1uRX3o6XOF3SCaaaId+fn3c3pswifjAsGFnr3nMyjTH3SsKxtAjUTYu+ysDTAfTDzHOtQYcnnk4IptQ8tfktMFGr7Cl2RTJeHkNkJvGs8i5+3RzfoIc+jVXUDeBthSWtI7+KTopjskWpztRG12tFArarPo1xXSHIl1GN+UnrdEWr8FbcmGh0OszLydwByQ78kbK/Lo2IpWo2+uX4X3WdvuITfSJMSswJtFOhwK/omJx/+6iGeH7Of75xBFxSJyFMF6EGxC8M7r7FJO87ga8ZbQUGOqRpFuyJKVCXQc1njON10tvRxoWuKzFMHDfOJn1NI8n1JzaxGzwwvnKOSJFIOZhOeeyRxw9UbqVhdOp0VT7Aj//+A20F5TbwkLY80ElL9/wRBUQ4IOenSMe4+FnxE8cqxUx8YzqQ2MaIkVnk/xqFuUFy543NUnfjiAXs9uShl+uvOPJR7zxdlcfjdV7BrO3yFlHAzWO53fGyhFmC0IhsIeumam5QOuIDZWS0YyaRyO/+spohVulm0fpqeuU2/pvIL0jR4CRc0IwrgaVJPq9EspEjcvCWB5hhnavgu+o2A2dkQin+i7+hWKI46o6LDHM+x30AunH32a8ZmRDozi8e+lkKtvXY3NJFi4Kt54T6JXZW/cBGFZhvxicCoSYFXB1qKPOS4oiuJeEECAwEAAQ=="

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
  password = "P@$$w0rd8913!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230407022916561466"
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
