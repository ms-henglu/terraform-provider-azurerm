
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031751167815"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031751167815"
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
  name                = "acctestpip-230728031751167815"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031751167815"
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
  name                            = "acctestVM-230728031751167815"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2166!"
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
  name                         = "acctest-akcc-230728031751167815"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA6Zlt7+8Po3k46bRtT8nww7hm+Rj6GHMaQOWvwlmfdgSWwccxW1SCX5Dy25ObsPQPY6TZxVCED46pXfMtem+3nmDaleap6XEAu1JPC3h8Jzqthqfssr2PMoqP4M1mWkhGLiw9xAnpLNI4aPIPDEjxkGz+cXWhJgGNwmM7J7dwqidremoF5jQVKsWfS6XcVYnFsvKBDxfQ1dj9PL3VKZg5AOLvQaRmrkmeKJYP4fGTm/He6QHk5hQ2xBCcZZcIDWaCEDmcqkcJU+nMEuqeyEFnIyoISjlVizCgB3hG12PJwlUey3ED1n5Vb5YgLkt9vXhApJ6m1Lh9+/sodSa6mZZ8ky4YI083NPvuk293vVZQDUirt7Gn0iKclF43NJIzoyZT7gKyUQusvgpLF2C5W+54M0WKy7Tb2hQCJnp6eGSs7wOxrxzg1XTKPIm+bmuktHLRvJsYCsZjnUPtVG+fDq7rD9kmA1towh3MFyf76I4ScgiuXPfLIAeSL/D9i/+35ql5nJcfgEK0cLKn2ja1knkDOWOrJnzf+y/mZwj9onndimjBwMra3KP79mUZH9IIASxKUMPKbaZyNryTtUZhOvTcwvxm4NZ+tWyu0kRw/Xr/5D4vgChoqoN3CN2on7d+BYlnp2+rSvlSCwuSh8Ul/4b8UyWCzJ3lq8FFqoCdRco/UiUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2166!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031751167815"
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
