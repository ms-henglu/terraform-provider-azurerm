
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021515049244"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021515049244"
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
  name                = "acctestpip-240119021515049244"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021515049244"
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
  name                            = "acctestVM-240119021515049244"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7679!"
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
  name                         = "acctest-akcc-240119021515049244"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxKhmQw5pC13ISppubiZfGQKMqyYAv9XrSgXgVeJagVcAFDL5+SnVKYg5JT/rvuj5ZfEgRUQR1c5J9tp1zidsR2uYlmxEWj1YGfWFczCkq5SjhhDIkYpy+AWvoYq5q4bRwJkeZIhC7FcZw4FR95z+TpAEXNU3NTSz14sDh2GHmG0LN/tAKQa3aOK7LMJgspvqZzSidns11Kg9vhM5qBjnAETXZXGjYVZXD+TpeO1B68E0bcNgteiMyLkPpAN7JAEDso97P8v2xmgBTykDQ/1Fs2q1bQNwa72Goh7JW4sAfn7rcWkzQLEhzvsDpcnrIgjCqjOu55VMocImznt569Fb2zb1NKg4WCnpSKFve+UM2zCMBVxnPnXSNywhm+QUW2e49V25qGXI+ZQc9ApDSrJrlVNzKaXEj+T1aKWLqHjIejlH4s2oyHgpuvk9W5bQjqaSZBiCedRg5pYQyphOZ4y2HvvhznRqAE6OdgGd022hE/1sllGeuXlr94K5FnBGMU+2V/to0x9pBwsld7Dp3CflDKoGG711Vk4pG6DZznbgwujbw010fNEqIdKdU6Ehc1+3TmoGKfbQgSbse5rgYkgbiiMKtznkZQcXBNQE5/+0751oxIe0GMSyD3XYQuthxgxtWXYvBmpFdVEcWCICSQ+DKuZF4f9Ps3cgIrDyLVFoxE8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7679!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021515049244"
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
  name              = "acctest-kce-240119021515049244"
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
