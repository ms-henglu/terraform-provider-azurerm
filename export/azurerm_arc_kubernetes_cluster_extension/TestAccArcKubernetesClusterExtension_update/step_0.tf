
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040526428716"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040526428716"
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
  name                = "acctestpip-231020040526428716"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040526428716"
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
  name                            = "acctestVM-231020040526428716"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3509!"
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
  name                         = "acctest-akcc-231020040526428716"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAouppJjnlTAMtIm7rDMGkwxBv9QIychxdv9Z1vBnNE1Zs/g5SWSB++jdUkbSMJdDs1h4Z1NGbxRTWaH1SFMCQ+CkQlTcQ37tkssc4fHSztC+fpvVamvvziFj8k6O7cfwDxEvyBXmJXWMP10eHBf7KWl1ox4No9tMKwgw8+4BfH6S8RFPNX0LQDQgEn9kThnWXzq7wPNsfHhjMjDHbwU3RRQt0dUg/np6GMSKbNaod2S4oKQd3XGXsm+zlCpIRPxpB/gENNBRp0tw8w7xmfL3yZTMcM4qlXA7QqTVcfiUlxFn7MvOgUBSQnbUa2JTVfwRxhSI21IjKJXkm9xN/SzUO9j0yTEga5KynOIZX6BR3sX+LuwrcMWjT8GcZZsH0vuU+Di+S2Z6qFx5M/BJPIsOrL3Z5NV79RRkYPFOM9DRY4+ZSXSFV3gEcI+obHdCkgo/gGGSJyWI2hi6W64HmQVXtXZ31FDX0vlSFrAeVjKnl8odAc6TNHLOHhm95fqitC/04Dc58KvsOYg7KxSl8030PjK6PnO8OLvboOSsqfL8vvi6nyONsyJv9ayVlVK2NG7FYWr+Fr1TNhnfLQlnJSemvtunl0X/4R25dN3AzjtW9LFwpnBEZPgF8pMZQ0WPQF+ggqsS4zYIHZW59kyE5JLd7nUcqVPAx4OR339cH4hAvTacCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3509!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040526428716"
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
  name              = "acctest-kce-231020040526428716"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
