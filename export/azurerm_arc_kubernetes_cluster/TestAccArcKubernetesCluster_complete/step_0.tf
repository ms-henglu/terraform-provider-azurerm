
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023526170085"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023526170085"
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
  name                = "acctestpip-230818023526170085"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023526170085"
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
  name                            = "acctestVM-230818023526170085"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6391!"
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
  name                         = "acctest-akcc-230818023526170085"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAz1DexrUU9kcwr4cAEGN1BkkyjJsCeR1kBALN3Ds5WdugjF/1B6j0+ZtZkIXz00ZXok/vAYIIdgn1DVE1eq6pJAhH/IUuYNie9G/GG5C2wxU36OhTBRIKh7H38UBDitsUwtlXqT6sOmbtNPRn1SGamPUcFnKRm3t6aSaHVj6Igqu+st6HsFFST+IK7g160ShVzhafYuxQbJb0sjWthMAAymzzEMCBqdV23Mhily6x/608oZ2GUTDy3fN2KzCero45IlvntTqSjmW8WGLVNCLLR5jww0fdZBufsMa2WjKfu97PnDFS2yqdixsYLi4jUbeiv1YS9gVuHVGF563vIjqT4z0RWm3zA+5xUQraSRvMEG8IWbsbL9s+gm498RZCeuZXY8+trFlEIeRJuGHcY9l1aBaV6kfqzZp6bRda8w/+rjWSkd3vqCNzPfslZHFLUhdiwxKn/RIuu6a0PftRuF0ulQCWAuM/8KVwxqM49ozyiJB0ELum6UT96SCOtFIWgzUCvopXqxiQK5WCORNaMXCcDy8YOeDImkL6V94jv022WYrNn3pkqBERZfy3Wyy83ea3mVZGG8FZ0fXOTwv2bs4KT1sC40NzftAzwkLyJkKfXZ/FaubCAOvFpxl/VoyxCMQQeKvgOX+nu8VVg+cTH6vKNbkRcrerOLL/twXx9ig4YpMCAwEAAQ=="

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
  password = "P@$$w0rd6391!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023526170085"
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
