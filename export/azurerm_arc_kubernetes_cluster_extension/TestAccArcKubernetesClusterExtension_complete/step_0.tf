
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063249417068"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063249417068"
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
  name                = "acctestpip-240105063249417068"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063249417068"
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
  name                            = "acctestVM-240105063249417068"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd648!"
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
  name                         = "acctest-akcc-240105063249417068"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAz4P+0MSxKIqLKsi5EJR5lmAXK9neBR2CXhnbqRkeivgWXmFGopBwyJLMHc6kjpEaJK5aGwLmYQafwVDd4cjZOAECwNHM2l90dJ3zSFckjwz64UmO2SAPkR5e5L2kpfFf5NZMg+bEAqdaNbgyVaGC/XjUqTEOmmY7DgtfURBENsn1lcmSqmhuSjsUxoO9R4ojxZP+SO4G4ul0nzovdvZlfMKbci2ruuKTo4O2LNEZqY8WMHCwL+Ycwp5i32/KPA2MbHiZg9A3jz4GNBaYtx/jD8yWaocs/g2wFoDS2OpuH5qjUY+Lg2Kkg37UOlbgNwNUxYAu1iF7bb3eVs1ewAmP5xfeIIucX4qBdhXZizXV+mP4U9XbfNiVdQGljBiKMzK7zgOOgqfNuChyUrpMKeuLFanG4+WcbPuQp2qKrxSu+mPrLolS7Nkb0A6t0R8lRx7NjE0Fna5DROXPdTGtMdrH7HQtYixl4gEpQ++ltdIMKDhXP16A/8NBNDSCi4xSyJ+vYUEDCHt24U2emAPNSudkPIPrM1GTcDEEAzKBti5PFgDq5hLf94ox+JagHq0IpTvyBmqou4eoA9mvkassSqh8RrsFzTcZj5TZo+8fVJFfUVcH1UC26CMfo6CoeX398dv6WIXrAn5e5abOKShWi4mkyNUlHUpVeYSq+TgDRKjn2JMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd648!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063249417068"
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
  name              = "acctest-kce-240105063249417068"
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
