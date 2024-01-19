
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024451833303"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024451833303"
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
  name                = "acctestpip-240119024451833303"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024451833303"
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
  name                            = "acctestVM-240119024451833303"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7906!"
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
  name                         = "acctest-akcc-240119024451833303"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyovGjmlAn6EZPdPBKjqMzBLknM9K5HTwPrbe4+uUQrO+vQnJ/7DKiieeiU3YlBOPP3EZAI0GW+fsw2m068Eec43jCgsCN+8aNt3K59M0lqQ4yD9Gauq3CXjt+qJ8gKnAR0BzE0b1FT/qh0DI/hoECmxGigk+bUu986AA2+p9nZ02jOMULI/Zp+TgpGebtHZIw22IWK7/P54kgJ+Y5qiHF1e9JB2/b+jd7SSIL2eIiG9Bs0q5E1bZOjYackqebiGhLEHgkCUdT48hvm95oI18+ouIZaupOmITnC8zkcC24Zpr9BUpk5Garu2buhD8+MgxMAD2fml032IHbaii4XqNaGn0zUP9cnL5ON+gUsJ7zozmUtDnr8Wk8a+6U5g4EPr17VR7ynKceBrWm0VWim7IQbTeh32jUf1dr4zbyFyT4CXlsj23ts5zoOPbQRnBtz3IjagfqhPGlrCAa+QisNcIM2NaJ6oY0bQbhd+9UaRzuUmPBf7t2ywjHyYgm9jrIHqgwvZk2PgJ+G+/EsHqSfyxEJRfQjB1BZHE4UPIT8qNSDH81c8OxInkp2lLwir3sh48rZzvD6IJUXaHm7Iryj2zPIbohhoIsbcOBP+L9Tr3yVTf8oDjPJyslknnhUKptd8OtKBNyX98LP4H7b46ldN4h/+kaI1qZ+eMbKcIZmG0/BECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7906!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024451833303"
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
  name              = "acctest-kce-240119024451833303"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  release_train     = "stable"
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
