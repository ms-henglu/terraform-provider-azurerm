
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042909730031"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042909730031"
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
  name                = "acctestpip-231013042909730031"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042909730031"
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
  name                            = "acctestVM-231013042909730031"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7284!"
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
  name                         = "acctest-akcc-231013042909730031"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAoH8tzRB7X89xQYavw6eEL2QGJZZbUqA22pzfPrcCwTaihUWZ61wkt0c6Z3JCYUkF6xFau9Iywbl2UhUKP56xy4zi1SaNaOQDO8Z/n4mYqIcuhVO+adojwAu6Yy4W/S2mHbagz7btyESzzK/ddLgvpY1jxrxOSMsaqnZJlhYjzoXLrpHFrBsmhAcFRwz0lDyb/DNIwYNYmBy8UeRX/q8g85n5z7fw9EJ5ea8z0OiTrUtwal4zZv0IFG3M2gd+kKo+JPJ0bdDb5XVdK2putj/qNV4fUV0y7qSEOyJkibFMNwOA31RPbY99vGxW1ZspBjZuoWDqmYLqIYkVr7ap47y18k0klSRLG3c/ekhtEB0PwhY1h9aWu/bM8BRY5pHMQY5GNKtBSez7NgeBDK+LD8b8HEg9S+jb3NTxgBBHjDh6gA4cy4Hj4ZeJ9GJwJ6j7nmUtzc5UdlAX/kbL1DX2nY8PmfVtAV4xx6U+ktXYoV2HI+s9Ms/e52HcrPiqJL080oXXVEu4VULcnkSPCC6k4yW96WR+CV2pR8550SZMXcWWtYK5vWXz7fCUXjDupuw5IF4X91mhb+O8AB7NFb72CMymFGJ5gwj2CnDj24MpNCETeOZ2pXnkCJ8QZyStxOchzi6xyeEwAxKBroUoJ3hUaAb+eWORev9WY03NIZdLPbnlfTECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7284!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042909730031"
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
  name           = "acctest-kce-231013042909730031"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
