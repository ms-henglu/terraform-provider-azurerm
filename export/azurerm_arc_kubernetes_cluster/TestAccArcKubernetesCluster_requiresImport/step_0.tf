
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033351247072"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033351247072"
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
  name                = "acctestpip-231016033351247072"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033351247072"
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
  name                            = "acctestVM-231016033351247072"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd846!"
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
  name                         = "acctest-akcc-231016033351247072"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4rvFuHU3dDU9Y9p8SgnFt04cYenohZ80Rb2VOvG5wlFyrRpsYdi+QvA2JrEwIf8J0gz1+J0iJEg/ztgxVBKrVPGLGQqSFl66jYcTY3pYnneEEB9A+OqEYY3A98iL0b+SovFPjDdBpOwR+GcQhu1EcrFB06DFZGhPWuDn8N3kEbRh6ln+T0pqzRG9tOPiA0kVz4xqFw076elc/iev1FJflTFsF9VmA3YBqvxWrmX20It5vT/jNenzDVlvcqUmx7qBYPoUMF/UnhCOBSM5nmP663w0Wz+BzU4FI8mUSez4+hrFX1zccl3AtJJmosfJIPtIjB7Jn7ZWY9vDOTd2SzPhtMkt9NphkVY39UsXUoq2mcgnBOu5TIWlMnTobvM5s6YToN3syrDpxuNaPck0LzbAIL0tOUVDdsyt0AjO+IIk7IowL0MKlRxuK8KS3/ZsULVL4cmzwK0VPt3wwchYYDB2qgnQ49/9ZESP/fu7Y9S508k+FynT0X1IOxuhgEpFIGvLm/RNqll/OyBBKE9VARi21p9cQaeApHXRm6X2ff7MlRYFZSuXhIGqDRwNUAbVEKxxoanbVRarwG0bqAad1xlkVZLwPCfIawwDg+3zWHhov6RzRpYqA6rP3NLk3Lo1rG1wD/I3XMYjG8x1izXuQweZRta90QBaWblgfjBUTDjU9LkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd846!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033351247072"
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
