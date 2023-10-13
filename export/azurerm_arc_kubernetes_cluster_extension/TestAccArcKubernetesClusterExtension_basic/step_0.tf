

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042909186074"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042909186074"
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
  name                = "acctestpip-231013042909186074"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042909186074"
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
  name                            = "acctestVM-231013042909186074"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2855!"
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
  name                         = "acctest-akcc-231013042909186074"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAmNggFdaKkWoV2nGKARkCWwncID1SV58Tr1HtoLMopTpDf/Zah1NLDJracS4y7a9Nznc2GQRx7nk0vzkmok1lc5PT9ywD+VvfN0ApTHFVJ/khHT71UM3GrMiSzH5J6+EmjlOZyNsMEuKP9DKcurXhehmalPH47UVr+NG0QFNwlIYLqk2WK+sIRy1s30bPyq7qLuUwrbMBNHULKGtfafbbkqUnMLsxhArz+in7yQwro/Wb0QKocmgz9mL8WO3bVRxUfbYbykTgnqAImlpP97XJsM20jlTR9Hfq6OEZqtMKOWoNMjPF2IlV1TvjAfADxa5peON9saNHiSTuC13QEQ3RQ0xrbLX5Zv69GR5QXBmcHICsBxvzyyWpvZ/n1Bj3HK4XB/OO/1MubBfCPKKfd95CePXmTsHCDJ8Vm6eIOd9veUG1aBYGNOE2Fi84Mg+Wx6ghRhGwlmZfKr9VgHGviCiiboX4oIvRcJC3A7HrhJvF39P4ztByno2P0heZaNYEweLgCWHjahT6g6lG67xBhx0gYPTooveEbzwSy0vSDxaPDB/b59MMoa72coxACfxLzYSN9ZmyhzyVqS4nYIeh1Aa2NwNkh0QkqglJJPm5KHFN4YR5TE1xTA/1bkvldVOOLK9ZQbvoCEis6C++iMK9p1lAG/iEc/o6QdApRBVe60zaO0cCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2855!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042909186074"
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


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-231013042909186074"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
