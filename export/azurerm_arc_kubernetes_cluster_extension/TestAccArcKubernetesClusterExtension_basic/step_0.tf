

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031319120711"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031319120711"
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
  name                = "acctestpip-240311031319120711"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031319120711"
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
  name                            = "acctestVM-240311031319120711"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5497!"
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
  name                         = "acctest-akcc-240311031319120711"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAm+08t/VhrJkOtuN2MQAqMxvfLm/zfDa/pzTLdcUfDwXcwBLbxHL0iuXMBRoIhrPQZui83q19CZRWZE09opUaDt6E59X0cYz8qjE9R+CqU3oTjlapNHyEe4yR1eX1O4+Ts2PhcIh/YxsxoFmH+/BhnLCjv7km2jTQmLDfoYalx8cN3xRwAv+17wfrDvwNt9ggIgmnx0XOhgoq9Mav0++lVqe0s/uQ/Vd2m7lVlJwY4B/fJjcescpVsBJH0OW76dxWtLIks2JBOpOZeNZBoRR1z9BxsnKy+0U/TEKLQDjkaVzGtorMeVeW+BO22p7bwA0+lQfJXPFg+YsJ/A7uBH5xWwVxf/leXuEhp21Df7dlIUgBpC8BoroEGhxOczdlxt7z8iHOVQxFKYGefRUkNRoX3NWd9rnwIMnApjcpYpB5R9y++UdqSSAwltawn/e5FHfL1EaoQ+gcQeWPttf74ZPnnzbf7fpWPlbnXxrsI9USa3MTWWUqggk6CAbU8eH5mghbaqXGaT7KXjN35wSfu+G6B/pRBWfKqhbIPL8s4w5fEfOYIEJI86vlqkFniE0IAApYPxSCsH08BXzqzDdM9Vp0Xe0nNCOA8j75DCdu9HcnrxmLy362zJkK+UydO0IPAE3YWAO0I0Hy5DyLebVr+raZN9SMBUhAOgygaM7U/LNxW6MCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5497!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031319120711"
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
  name           = "acctest-kce-240311031319120711"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
