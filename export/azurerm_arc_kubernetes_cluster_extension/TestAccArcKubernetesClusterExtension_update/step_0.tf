
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042914628120"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042914628120"
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
  name                = "acctestpip-231013042914628120"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042914628120"
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
  name                            = "acctestVM-231013042914628120"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2486!"
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
  name                         = "acctest-akcc-231013042914628120"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzy3gweoSgH2X0m5PnZzkAAGsUNHqHJakjeElTWHqQDP61p5+55bZrFc/tW5PcQ+hp8/8/Vib7T2BmATfkI5lefnAMwCRMieJg7TAA4xzSZGbaRgePA0BAxsbzIFB9RO+xrtlwLgGbfSQSC7VVsEsJ2rxuqpfGla1Ae1Mxzl9XV0ae6KMJUtIblBh97bd2nkc6bXb366CWpFcqNczyNEz6b9YdhWifrSnTAhzL3enXpj0QJW1UPaHMQKifKYEEFk0AV7bKbOHdkN9BnolCrk5DY88N4+rfMvhe9HOsHFS/eX5Ab45Lfy+7OiU8fVQjFfI7b3dZYtSVm/pO/mkW4dA0lLD9p5V+qU083p6a9Br4GcJtEA94DljrzyooRoX0A33aZ/0qUIFOqayn0s2zK2zIfG6AtztgByEMpKqWHlAqMyXy9qbN4xlo674haOshEA6XjAou3YIh+Z7lFuGjpoV0/TQC2Jm92tBzSgam2b4oz4T8HeyGPekLw//My78wrSjx1AF5fzXEoyJdQlF5Iu2TrigFjuT/YxnCjLRSftIn+Dw1TDfrikkOcpWT/1UNhlKFzoKGWVmWjhiRCkBb9PKYI2ARIFfNNOMuuotJ5kumeJglJki59q1eFGR7SS45DGcC2mAFFRypIII3ScQVAQmdCH0KQ/L4YQfbifEfERAiI8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2486!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042914628120"
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
  name              = "acctest-kce-231013042914628120"
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
