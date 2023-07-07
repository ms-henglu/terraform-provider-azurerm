
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005952677656"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707005952677656"
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
  name                = "acctestpip-230707005952677656"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707005952677656"
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
  name                            = "acctestVM-230707005952677656"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3676!"
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
  name                         = "acctest-akcc-230707005952677656"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA9cpAD8+c4Dfv8b+RanWGeyyr7eLc9NtEtIXUWFpJtW/kcms4e/XbuYXZoTPoHTEJbo+MGkmrt7HeD29OqHzGxwRWqCcUWKqhDcDQlMpTkayG7lDmowX8MW4fp8Xsl7Om6DgLU5W0WOrMq0a4A9PUxNPPLKMS5QeNuK64kSZaXZ4LX4VBS7qOvfseFTLSdO6f5FUVhMoS4g5UAwXJ9YD3Wew2/L6klH48DiaBcsu5u1nXENRh28/o9scb5DbMxz2RoLPXZAmOPP44Xb6P9jx6UAvW7P7md47LWX9ivr6vHH9+H9ICaWS+JzXHwbKBfYusA6sCUufCjAyX8hcqu9XEKhdbnVLPaNI9ZAMbf/kETwFg190eFWvJZW5+fL619HJ3aSx/Cs7rGUcTaVtbNzhbIFwktAaOgmIROEVU1cVY+5oB2aVLrFzuwhnkn4BOeOsfuwHLjxmzWqDQNXwodohhfQrjKsi/JpVX4LtHmxZh8Qdm3OzkzokSveQc7m62BI4dFDTJ8kIkGf43z8ImYSS4wr4QTeDjhnr+JlqyoL3lA0Ft0DwX+qUBy2vxTg0OxKV+nVr4oNwQUtCZiKJ1DoVvf6TZr2A+H/9nZNj4agP0piNhH4PeL3y9vf0A0iwv9ypaDuWmpFN7K3JWI7ZDlyNResY2zDMwXokaZB1UhO0dUrsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3676!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707005952677656"
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
