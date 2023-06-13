
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071337399208"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071337399208"
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
  name                = "acctestpip-230613071337399208"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071337399208"
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
  name                            = "acctestVM-230613071337399208"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6322!"
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
  name                         = "acctest-akcc-230613071337399208"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqA92crG3ai4QeWjqaIh13lhWuhZBjVsmedxOGk/S4bJEq6f6FNc/SDKwSkjfPyDEOlCio33xhSSTCOgcthMUmk0HhY2TrE0HvFrkyoPgw7Rdch2BiBrGeBgSyWyfMdDDaYdIvpWzNn2JeTTXuGWZzjzOT5L+FHOVP9d8pawMs6PbIsL0x+cf2puZk/tF4oMmNUtfX+i+L3BDH2CbrwTiEgbvB26DY0SGwP4JkiscpXdq0Ut9QOEPfoKDXX9s7Z8ZyxeKD2vIwnDyXffcptLrDKQIOD1C0FIXJ4xO7e/byUa2XFmX6sXifLT524PplnMwY/WlOCXlF7HoVF57rxxcOK25KdUBaQIzzhhdCrj4LQLPi2QaaDr81ly8lZV9AEAsdIYGATdj+dBSieJWb9wgL9jV/s1CF0XRKc0rCKHe2/jbOp3pX1TdNPFaRyQlYmo8mM1V2ipjjG0GcsZUYXWglO9PfDRfEpq0IMLsc3DG5YxgSMbOiQI2KO1gCZSbHfc315eYwG/FVW11k7y141u9Z7utLFKBBX+cMQMIr2dBtVHIblrvmadhoDat/4dW0t3D0xsHAjgoIm9n9n5liwMViJOyWvFfzMovpl80oKZTahsmLjUOf4ZhGd6wCPc/rv55wNgxHhuOj7hqp+eFCrDU/LUY1abb6vO420ClItt+gr8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6322!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071337399208"
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
