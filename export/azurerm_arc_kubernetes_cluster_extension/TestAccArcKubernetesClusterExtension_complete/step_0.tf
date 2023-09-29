
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064343363490"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064343363490"
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
  name                = "acctestpip-230929064343363490"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064343363490"
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
  name                            = "acctestVM-230929064343363490"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8450!"
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
  name                         = "acctest-akcc-230929064343363490"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwS1vscf3PuAdWjBwecI9ioleFL1qWOZuRbIhOp3zVka4gC1GFDXbGNMU+zgUD2YPbeNuvKlcxuVZVuYhSS4ikCoHDBiRp73ZUPRUeXoWeJvYkBYFpmNTUemAbZq8k9TuvxPdnoDqrXwSJi2AblbloPq1aRJJC3lu8ZyEyGVAT8bFCnOMLGTjluLksy7xdAlq0C6l9s3M1iNGSjplRdPgTgU5U3jNBL9sfkmQSDG51L79KNpaBDG73sRXVlXbh1pqIp+3rqe0EEECNiT6KsIi0c3Lg+1ttuWgUOGny9P/YXNoGrEZudRCIASwFZjQvxR5vf396n6iWT0GCZyY70514TVXZC0lapsWNspMQJjyXl997P49o+wdVkiuqdzwtyFHU4ikSDDFoTIjiilOcbpEpZHVE+6+bMuErmlK0xrtGUau2AvvCZcts+++nibmBj7EaBuNxpqOOnIhhXXfBB1VsUJHVGhrI8S4k6DCvdGLwJLS2dQfMpytRz9Jb52IdY7KqDJQDnRIgZuaE4mwciAIgcf+jcp348q8DcIkdxjVKG/lm6NSHKDEjgGwdO3Z/d9fwuyTI3CqYuFRLSpA4QNnDfkC4L1r37kxxfCK6fw8HTp0x1pc1cNuCx81AXTGn+hdFsrgGWgQtP+dv7RQo7eJn2Y+MVFaALFWUf9mLtKCbI0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8450!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064343363490"
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
  name              = "acctest-kce-230929064343363490"
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
