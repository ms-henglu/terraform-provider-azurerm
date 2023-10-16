
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033350746984"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033350746984"
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
  name                = "acctestpip-231016033350746984"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033350746984"
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
  name                            = "acctestVM-231016033350746984"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7451!"
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
  name                         = "acctest-akcc-231016033350746984"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0abIJaLFGUPthQGWb3Z+DZDrIl2pOKidM/bHjoZIqh0p4sDF8waDzCzqVHAIiAhiWslGkwraxG5jLzuoeUZ3v2WSwrOkOdPA0VeWBP1WZ6MtY9aObXmJwZw6rU+2u/0ip4ut/IdB2W0TXkG5RLv9ba2FBcj7OOQH5pcHrieu67WK04kNbQGG9zKLQLLQ/Js2+3HA4q1YdlJSEzrkbytOW5jntCiAbXe0yie0S9gvQRCTeM7Mo4Xtap10EANsCkEApAKLUTeLymDjnd9WcouR2RihEIvDSWfZO02d76+dEJHRcSAu3CpdEqKicqbq3O1rUgOx6WcOmKU7oGDTML60nA8XVnz3svykfh1rsjyHe3DcJ8Kld3FGbUro/G3VBHqsPUz/HlVP6dYRwAL+3/5U38TVyGmb2skDiB4TzcpYlAWe7cJhAeFsh+W5JTg8xPMsYhyeqQzhgjqpfU3afkyTtzfBucBfGkfueFTY0tbtrj7TMfbcW5THlvCTwW6Uuqkg50cWa0JXzdh0ur3Eb5Q5c2qDdLk3+mjIYYBOOgra1xsJzSz1zPljGzDi+1yHb+AIUrLU7I/3ieYETcRCKkomBTOJi6Ykh/VeOM2EE2AHgyKx4ZnmPz+zS7fZwEgFUfjXWT7NwWwzHMqS14q7XO2chTSN72VOynLAKrpKJ6zgsCMCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "TestUpdate"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7451!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033350746984"
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
