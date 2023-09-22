
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053610917902"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053610917902"
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
  name                = "acctestpip-230922053610917902"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053610917902"
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
  name                            = "acctestVM-230922053610917902"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4328!"
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
  name                         = "acctest-akcc-230922053610917902"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxEiW7r+2ieWBdd6thCk6iCoiaJUjP1cplRw/Fi+XE2E55eJ/0dd4pVnmDsJO+qkTdrNwaDB2xKqHAdHXm2jnUdtNgKTkBTZgPPbUMwDZV/1w5KJq51wiOYseeVBmrP52aykTCmv6sUq0ASYy6hlr7pa15bKCcvWDl7CXFLX/VdzJekBr8JLjeBT86+RSzWgXFfVM88h7M10gyOjI+6GnEBSK8R5Zi66IOauGj4hTzgl8oN6yZx/pELe9HyHeg3q0eOYGKSc80srp9l6tKUtEI/K7NmnnaajmJ3RLmz2wQ1FKzMB7Eg/63VMN+qhm/H6iJ7i/C3NnznU5qMk8GQFGeMnQp+82d02eA/DTNTVhU7qn1snwNSPMHcjoWMhJdENJSbNsouHBGxTBWc0+pbFl76F8bCq5TIxegWjmme2TxfgFt3Lm1JO2pVGKvOE6KrL7L/noMYoINSHkZf29p1HrNNr/GYwy4RU9ljuth/mCW+27VuUF6mgzwmRPLitRat4ey6gUp7a4iiIyWI2k8tIrSUdrC3MQxi4pOOZ2wUpCSPgrRHxypOR+VjJyAaw0bIyzlfkc6j/q2YQ7Bi+dLS6WEydoNjkVnvLglqZGi124TB5kFaKspVEuTrqo8fgxxzy9idQh0nSwHf/arffGHznW+asP0a9diiRvJeX1BzhQousCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4328!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053610917902"
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


resource "azurerm_arc_kubernetes_cluster" "import" {
  name                         = azurerm_arc_kubernetes_cluster.test.name
  resource_group_name          = azurerm_arc_kubernetes_cluster.test.resource_group_name
  location                     = azurerm_arc_kubernetes_cluster.test.location
  agent_public_key_certificate = azurerm_arc_kubernetes_cluster.test.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }
}
