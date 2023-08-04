
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025431845057"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025431845057"
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
  name                = "acctestpip-230804025431845057"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025431845057"
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
  name                            = "acctestVM-230804025431845057"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7021!"
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
  name                         = "acctest-akcc-230804025431845057"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAmodmSDHaq8GbtyVXW+ah1OT1Waalz3tUwO5mGPOctlKdhBtHFF0atbcAzvBlkN6sznelaUAz980VbDO+eQzG+2uzDeoHzInbu1XhA9VmxQgshvdnb0w2C56PS4YuUxpLiuFEg4mMIiSLv6Sxfe2JXOugblWEvz0q+04qJb20qFufEhDefuPZ+UfRgHvgW3inblazPYurZx+SJ2Nr206NuF7MRB/yaOQ7aqsCYXtcVAiVoAJdpXaY4KkJifReZm07Wf4bgDAYuiYD+1zwanRZyOD6UCgvq4KVN/RPWiWG+VnWVPNLF6VTRcp+8AuBBxL05Jkq3cu6ZtMLcJoF3zJWSf4Z5nI789m6yVAb/ghICoCpTfxp6enX3uy8A+CpeLDGF7NOL0/Nkeb4VoY46QZ1VAo8jgvpn1GMJ726Wjm087ih1s+rVYNeAgP2bHKlLGRS1nBL7spi7msQpxp3x7tltUu1I+nGSnOhLtNb4VzVWe7UvaFQFsvNyIcazYaZJBHkR25Z3XL7jro06ipxZYGmiD+o5yibhWrN35rPEelKwM4OXwQPWDC0+B16oVutxNWg9lZYpo6UEyEjw77fmeCu4Yxfyxsq4ab8WjJlqc24e4cu+6VgZgmrVouvRJZNRgP+ESvpUoyIpRMDwioO2SnUqaoyGraqe3suY8gZA9k5c88CAwEAAQ=="

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
  password = "P@$$w0rd7021!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025431845057"
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
