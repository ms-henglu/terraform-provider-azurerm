
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033821280382"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033821280382"
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
  name                = "acctestpip-240112033821280382"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033821280382"
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
  name                            = "acctestVM-240112033821280382"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3285!"
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
  name                         = "acctest-akcc-240112033821280382"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArjoAGpF5FiO6nLPOnNuOHKRBvtK1WCdAil0CsL6TD+0OSeQOpab9BOGpxOrlBZFhy9w5uWoQvdHlT1lqPOWoXvY6CsiWyOtjZw3jiBJy0rNJlCi4v/WJE1ZFFNa8YyHIKOmHLAcZo0+/5m2Zr4KqQa/7vL5xiZhqRvCnMrwlAuWgxhuPAch9DFm3155aH+02F/7Z1TpKFUKsYU1Cq30++c+MoJzvO62bAqWCrQZYJ+pT/MniLVV19UWwgcUMEtfhc2Zgx+Fyo+TQCz618KlMjhLhSpMSfbJyRDBVmzZtmfqVpTZk8s3wYEcUiE2nYgVbaOOlg+dKpETLuf91phfk1rq1GKmIagUqxDVckoSUt8bJbtHPJzp/Ic25qikSx7SY+RI8SrVJRmoBgfmkj1vuRLcl8EsdbHg+ltiMeCBwSyD8Vx1PhD3ePLqlLYXK953d4JljI7lEO8e7QMD+aTRZNqM53BuYnRhzrpj4hM94ZMrsrDNLN8uTRnp+u+jV31gQnd+rswkIqXoAmY6Kz62Lp0a1OV+P53SOrMc2nfV29ExNoDo/3fdrjjiiq1G5EmmikB23GpoFL3WEwYMHrQhi8KTfPTTQWsee88Iq8OdALAxZf+j7ZNltIhejT6iJ1+zFxDMpp5CCZ0gZJolrPNlzsKPGHsPnUbUzZdcZZaw0SFMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3285!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033821280382"
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
  name           = "acctest-kce-240112033821280382"
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
