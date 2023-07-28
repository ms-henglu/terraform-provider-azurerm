
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031737767631"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031737767631"
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
  name                = "acctestpip-230728031737767631"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031737767631"
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
  name                            = "acctestVM-230728031737767631"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4342!"
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
  name                         = "acctest-akcc-230728031737767631"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxyMxK9bfbeAuqBN1NQV8qQLkR/bnaxYNcSOaCqeVwSd07G7ubiZL7oQrwpYOsG7Vl+GbW5MfOzsjFpvaS8D1aAO7Vy3FHEuiYnZE5RdiVwH/2uIJiotmeOLKlnP6AL7gP8DJatYdRKhfbEYPRGFdHJHJ4H2b2ji79vaUZ9tUU/FL0W9kqaQb86jGAoQxSvjpqc+1S2boxFKzzoxNSVHOhAlEtBAG+G6HnoJke7ezANnVmRG9gDOJGu68MZONbCsV8am7qECDOdNDZnjVOsSOSUMod5c2aTNVEyBcAZ12cRrdb/dFprMYi4p9LIWVB1x8nFBt0IyVy3H7F3Qc4ZTJKu7uhFotTA6S2RwggvTH3DIKEYkwkm31iyp8tnS7YXXKt7+6A7HBzmUg1oG2oVGrBuTB+6i5zy8JTd+vbr6GCO+2dIdZd4DPqwGUBlzxGJdnuqoG6AqxUfIwk0LO8TtiHzg/QHdtGjEeqUl83NBkxcGxmM22IDcOOmzYaOC1K9cZYnrXVIOuiWSnH40bR/JoY7/R6GlSfAJKmdZUxUBH3hqAUM7VjI6V8oNagIph38FQGyer0QipvLoHJLBO/XR7BNBnfMiBJF9eMIo6ASiucqxzYDWbI/ljacibYa6RH+FA8ItSfdNVIRg5rgo7Qsei0l8qDBwmPzYOaqSfqGxxSFUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4342!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031737767631"
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
  name           = "acctest-kce-230728031737767631"
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
