
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071331512849"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071331512849"
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
  name                = "acctestpip-230613071331512849"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071331512849"
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
  name                            = "acctestVM-230613071331512849"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd22!"
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
  name                         = "acctest-akcc-230613071331512849"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApbCkxECc1h/6mc+Tgafw4ROSDAYBRlSatQwtEwMqTpaFftqHtfiNHrghmpyoTcPVFfZ+H6A2SYvrPhUPBHQYGTdS1LHO10MJdoZOVk5u3KQdy005qNDppv74lZAoJcdffV7qFhaGbSloaC5dwqDjcdbahOK+fT7Nfv2sbadI8jfrK0ddWn6OXWW91WyLpWPyZoWoQSfCy9naq7wxNFipVr0M27P1sJl9IBpcXfbV0GMEc4nTlcbDUIfmr4yLFJyUrY+4vo25fg1VaWwZQyPQn5gPnaHuAyWebHQoLpy31D16AMKnThceFvmZkRYtcVrQs7PQJPzE1pNKYNTM4zo0/gWaIK8Md0eX9UuYbrLn9fhnFOwGPr6Hk3syBDCYnVY6OulhvfJhUL3FkDc9PwPz3QTfHHuRO2y0LURQ2OhPKpcpiECvu8M425IVIee/uSxqlAExZXDE+kj1Gp6DGpg1/K7fGJ8CESgm01CtBSmMocra1Ic0Y9PwVJ6JmR/IFe1OpScFVe8QugITM+hgJtm47D8BPDZlvfafFTSLy52vqXqz9ehPNScC1lIfhXmRYK4Bv3P2yHg9vMghqQGVxNCnF7qFQKEYnupLYpt+F6IbfOc8QC8mYkHLT8IRMJ9EdkIqH4fcpw26h8xbI7oeawrqiSuZELWcB9ZOY6gcfdNZXjUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd22!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071331512849"
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
  name              = "acctest-kce-230613071331512849"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue2"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName2"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
