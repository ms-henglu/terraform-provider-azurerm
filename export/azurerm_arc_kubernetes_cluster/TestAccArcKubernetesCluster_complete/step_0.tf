
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505045855610473"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230505045855610473"
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
  name                = "acctestpip-230505045855610473"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230505045855610473"
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
  name                            = "acctestVM-230505045855610473"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3250!"
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
  name                         = "acctest-akcc-230505045855610473"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqFOTq9YY7lRHzRem1tuiPOI+6wUzsWPtQ+oIlIcxF33uz7D7oYXkCATRfVyH19fIwbJPRg1wWs53hw0VEaVKrDX1nQoOLeawsolX730j1znlgfguMdBJIXP7eBYcZFwhds2aahE3+EDlECk2JjiqT16pvX5wQfFmY4x0JYCEU9IASqP/4PJqOuQyFsoAegAE+EDWr6znbGOIo+F2CpzqUqMSmJr1rKPn9JxqIbM8lFlxIVjb34nnS38BRPPbhRb5wBr8dVB0chfHH2vkUOhE1Z5/RoCP9qwoKqkNi5k9DTgIUyRncmavNBy8Ba33bkgm7+aVSCc6rmyzUjX5M/TwH2UvCpnROjy77y4Ctf9zp9KQ4hdqvVRV8jvbcgnyuQA5eGfrWjrabY8K6FAjQbl96wg3LFXoQyd+3jkocSKAouaBBDywGvgFBX6UEbbwd4gd09GD5O2PF3QEjT1Ifwa1yTkrrNrnhFnUKKUGJPoudE2MzyR5qGXAMqVF12OYfd15JFmvkmyAxSh1t8pCkjzjGR6vxtRY/RT/Icg6+kIb8cqzubh/1p+stN4gB7PvQiflOgc2CKFHKvtl8xf0od7UjUQ2wqr7Oez/VzOiD0JNATt4ErWHO4YUVy6f/nmXeBQqd/gnlh34HkF4VpMX5JZYCEezA3mrETvKPupYlILtqaUCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3250!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230505045855610473"
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
