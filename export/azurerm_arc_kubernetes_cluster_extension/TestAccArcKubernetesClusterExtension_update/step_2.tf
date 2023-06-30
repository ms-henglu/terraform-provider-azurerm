
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032647184302"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032647184302"
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
  name                = "acctestpip-230630032647184302"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032647184302"
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
  name                            = "acctestVM-230630032647184302"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8072!"
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
  name                         = "acctest-akcc-230630032647184302"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAq0KGaayUop/OYC+M+v70Fgy1PggaEKBXsolYOiDtOTmDxyVASAVed0P5kSoKo7kwYVcrFZaGdse6RZJhgyi6tcu8oGou9Wv0SBfT9jQTxHuBLGXIOUPtPGWVD6RHvR/VOz4A5BuznC5mZrWF1A6KI9ZUEbcn8ahsbVxTLV5UqoFmalb5cxW14dpIITop/iIulRBqHLpHY2TZDcBfDLfBAqZPRNns+Y1GupGDhk4vHEna3A7R5g7f31VaO1OhXKVVeq1POxKYEJzrnhHRHQCMfEsvacRG2XiMmcyJoJJNwPKUsGCUYuwze4mhFhTm2b6zd8TyQcq+Lmimja3KvPzNN2zR8uhiXXnWqtlXBfVDPAHPBJsi6Gh5LE0BWbx8RfmlkgJn5ioMUE/arQLfJeaILCMPyzzwRJbBsdV8VJMBzb23QXTXR7hchbUFJTmY8W43Crln+E+fbhRveNqgALYcEvFhexXs2GlVdjNb4Lu9OP2DsgLRp4YHmMlFSAntqjA6tUk77fywhAYAVBwZku8PTKQVaTrj9SFuTqfJj3zLH+VkMRpDNsrc0Tx6OtkpJ5f2oVmf0xB5Ih0VK2saRaytSmh8LhFG2NZevv9ZoIbswAKQFM/qAsl9RyBM40Qjyfsmj0bOZ2txrkuuim0LHlkBhpCmRyHUgBblUtPwyA7sd4cCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8072!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032647184302"
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
  name              = "acctest-kce-230630032647184302"
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
