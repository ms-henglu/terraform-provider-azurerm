
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030139216477"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230602030139216477"
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
  name                = "acctestpip-230602030139216477"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230602030139216477"
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
  name                            = "acctestVM-230602030139216477"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6910!"
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
  name                         = "acctest-akcc-230602030139216477"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAs7rb6M9kSYGqt02VSIFB1/AskhKNzXoVdbO5cVwNNDgEKTR6szFZ2xPtABhb6IwfpEBxuTnAeXdu6ZecH/+XNpjfm6DR1A3HjXXLnZG/wmLFg7b3fdjLn6h6hwXBVoAcT17Z0Ak2KsYNyE7JmOgqzMclWu0KrMag6aEM/cjx8B5YC0KUaW5kbFhOFmWL/ahOSHF2SUhuH9Fm6lDpSD7EyzWbio99ocwjFA84aqzzmOLe25MtItPvfaPm76JkovedZ4qNb8Jro60/tVsc9VEHU74NpYnnb4MVzR4LZTRztuDu4BNm84ifs+oiNVXSG8g/K7pUhOQ20pMvIHq/OoeNrs+pAODUcIBsnK3eYqadpB5uHQW/78CSfs6sa4lqgew3IkLZ7TBd4Cfmah4SndG9cwySlRU3BcuH4S/44TovVVpLNIw+IMDGive0P58oE7LjIPE0W/B882c7PAfvGe8cx7PIqyd1IezKPwBmgw6W8a/kbtZrSd6l0ci88VfnK4OaPYMe+HdlbsLn40e6NiTaJG1aJi822osy+G5C3wzXcQMz0NU+elJg4+LG5COol3k8vKX67svx/3s7J5mwQY/WSpF89CmFe8kCeIjZKf+Id91E0Im3EUCt3YeyaaqlSznxbOWz087D5Jkh0gamQAwqS18r2MdrUQdfNBJEz4fxBpMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6910!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230602030139216477"
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
