
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060556243711"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060556243711"
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
  name                = "acctestpip-230922060556243711"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060556243711"
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
  name                            = "acctestVM-230922060556243711"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6519!"
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
  name                         = "acctest-akcc-230922060556243711"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAp7s03QNSTfQnPMCcZ3odY+yrowonZNsbFQiWmVw7aB4bnIOxsaAiVka38Iv/GXLKIqMOqXHxTxnChE6VxTL1NMJT1zvu5PpC/U9w1sQjnFlcjBXqIGH+5Q262HSM31gIZVT+NdUOIQNejqSjNU9KhDa1/Zu62iyzGDxHL7XjK2YzkF2rmeTzfo6LIejU0xJUkHzE4N3mPdWR7qUKUJNjv6P0cza/Ut4if4UPnnPiAVloJs0vi9OYqpSEb4wiPp2n/SQxwW8wn1SCVQlqosEshPuZKtwfBv4L2Z6/ctOqr94WTiq826zNvrQCamlFUlZswATMoEHLDm7wE8fZChFEraWcAmNIu9ZP9+gAeMQalD9HIg5sxnYkAjumENLBn1XrJF2XiSo8srjuvie5q0twpUsd8bKwiHX0LmQNtUwf8sxz/oyiL7hZimrreJSuBV8yvTevvPmXhZMS4PLZJe+vmaveo9ciYUVqqbsLbJjjzj0wWYoA1gVm64+3QDtkuVHI45sRv7fF4rjeIaddtAofE0R1rwiUIg72Pn8pN+mEL7gr0H9g0uQ+DuxYiJQOqTKgjb6NHRAUzpGzzwwERsjCkgxJV4gbM8akKx1aQ5zkL3VzJS2SqhE8QNUaXchbiHKo9QuMTtFGA/JkMV6bLAym7Tlc5ktc/s+j/Bvt0b8BIiECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6519!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060556243711"
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
