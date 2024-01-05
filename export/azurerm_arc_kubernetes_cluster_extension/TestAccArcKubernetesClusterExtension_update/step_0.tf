
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063251011003"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063251011003"
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
  name                = "acctestpip-240105063251011003"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063251011003"
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
  name                            = "acctestVM-240105063251011003"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9988!"
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
  name                         = "acctest-akcc-240105063251011003"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvZke754msnZrzXiZKmEthazZXtDJ4o5YsawmofDcrgW76mGQVyiR32/gnLv1+mBDNTlaFIa/3d8fnWXpCSGpsJKpg90o7Isfyt4tCUxoSfDMQ3O6k64ygSfXO5jpZ11kQJynwlk16H8PFHpxwM7UrhKxzGCfIZZUcdVNYvpz0HhnOG46uQrX0UP74yLE2xiSUhKYcHSfqYoJ0t9o+MN26/gdW8c9XX4eHTbDhzZU/ht8+ivLoTL1HBD3joGYtVracKEEBhw4YLu5UiarjMvHOwEGKSEMROhbB1CCu2cNsRLTJgBa+QGSiqOL+wbhUVlnTrtbofeE3o0C0IXiQEMvD4J5WFubSlF2Gcjl5Pc4EyxUun9/hM7IC8NO9VwK15/S9AWvcmLWesuUq5Ywoja/lLSVdLeZvQjeBDmb6N4M5AF7HyEZOMOVuBskvcakMVPC2IHAmCLJOizNvqKqN30stSK2QnifXrYbRnESw2R2ARWpboCrlJIhzSRKJlXdsQqPHcHf+VYTEBhkZy5R15x3X8QD1r8YrkloASLqbM1q1BQMjGgN2HhWEsJ5J+Uoc7Pc41i4bBVSxtTzdYZdVR0IMYeUyzoPbz3pDrq9AFBD0dy8f1keRRl4di9pgwBxuniFGDQtLXjzBNrtCo6Izy6W5zFt4CMLEGtU9vo3sKm1vP0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9988!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063251011003"
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
  name              = "acctest-kce-240105063251011003"
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
