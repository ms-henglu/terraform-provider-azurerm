
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074207547529"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230519074207547529"
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
  name                = "acctestpip-230519074207547529"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230519074207547529"
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
  name                            = "acctestVM-230519074207547529"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd220!"
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
  name                         = "acctest-akcc-230519074207547529"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxoPdZBf4d8oy1OUNJsmjKoD91J2z/fDFHfhtP1aJ3wNs078uzYamShxqQaZRMRjVYscZFkRLZWTBC/78lvjV4UQkbIQVXpRrGz0gPl1s+p/YapM3s45Vwx3BEfgy3z2pnktJctR7UXVNead5/Y24A4kO/t0fMGVkjtxS9F0uzzALwOgw8rKb+QA0pJ0QyMAjqCPxF9dAJyMvTUCNwsgT6GwpnMjmPPdT/A3D5enNQVMB2LC4mdRFjrJQ55pp8MYCyf8ox+hxKHmwKEX8AvKlm31Bq61M1GwBBQ97wwF74r2RWk1me+XBD/bHjxjeJeRzbaobsW6PsA+1wjHpM/G+DLMt/zppODH7kxTh+eHG7ee3X6AB4NeKql+xibgCjcv5enfmWC2zIylxAFVnf4VlbR0gZ/r59yLl1L1L2bKcZ10Fl9IHnLZHeS26tvAG+obfvizVn24ENkbFNGrYlNJCRo0aEmxbSIBvgIn8IC+J3FJ/lL4ARS4JN9iZKJ3RVCvNtWBUfdNryzeKNXgn7hv99m99AkCEyIkHW01hSowlCf8vW+D8EfUvSqvD/5fndi5qdWHrNDl5YmPm8DGp6iX59RPa0MuefUAU705AU/DEut78pb4QhCN45WxcjKpW5yxSsbUErPLYPznGQK6n0cBAM4AzOJbkJymiuvy/GmScmpECAwEAAQ=="

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
  password = "P@$$w0rd220!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230519074207547529"
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
