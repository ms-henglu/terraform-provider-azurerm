
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024029240708"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024029240708"
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
  name                = "acctestpip-230825024029240708"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024029240708"
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
  name                            = "acctestVM-230825024029240708"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8768!"
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
  name                         = "acctest-akcc-230825024029240708"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAoRk7MGU5OeQvJihgCgtaWtBjd4GbHkUqKyPa+2OsQJL6GmjUCMxz1F5R4sAifvqpSwfVnM+Aiwu558QSGyZuGdmICWC3/8Riau1HgTlkli1l8/F2TpZQtbL0NZ3xNr3K/AtvV+2UrJlQs6KUu/60zR5HHbkdW2qSr/OM/5RbpV2RMHyez/+wtM3KUwrJ6V3sPEIhrENn6uEEuxHCdRRkUrGxlqZIVY8xxpTI5x+ZwLPlPrcmZLmnhH1B4RcjLDIE7AhNIAXjyVMKXTNWOZ8ZTVFj5U7uljq3Cgee+fWdNi73lRcVZfDt+eVs6oqXzMFEzWg1RY8nwF9zeGlMgzdXhzRmvz2kkb3E4ABZ9xqpGqvSEu0oDWXUiDsVavbGGDtDlqvGg5Tz4oauO9d+eslL68LSw2E/ApGlwdcCJ6ljWp34KWLhIqEFBLKeYR+LY+auoTpW3Lw60BBT2NnWBCe7CzGkuUZUF5rfN4BytPYErgm0pZk+rKshjKu0tpnfHuKhIi3ql11+FBHk3gzrhyuvlUDvaqHf94BtA+7JyKW+sMX/HFFkkBuqNWFwLepb8TP8K73+BO7quvGCT0p7VC9jJ+nHAjXgUnC4d+qWrZoV8Z5wIa0QMIpKFez6AN5BKN9R/frLAs9XSYZM2qxsYHSdUlBXhBHzvIijD/ZvmAOzUkUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8768!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024029240708"
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
