
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033831725123"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033831725123"
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
  name                = "acctestpip-240112033831725123"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033831725123"
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
  name                            = "acctestVM-240112033831725123"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1678!"
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-240112033831725123"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwINjip18P1c/63+AsJ8UQ7nQKGyn+qEJmjRxmpIDf8/PgTgOXJkneHplaJaSVCjbLZzHheBgUs3vFBm9bYmnZjgngGi8D7GeNngPWBhBjLHgITD4Imfm2MsOLKolPv5Bmly9+EhTSauSRA58tMBUE+n3fHtfyOyZMaQ30b4bkNPAkyP/ZS1nQwCa/+yexaL3ov64t/KVVxJjhu8W76a7IsQMuHNE3u2qQ99/fGA5VvHNdqIiHWfw0kqOTxg0FDExW0mUGkqTuyKp26h2a7bfc+VMI3N3e8I67lnzhcV3HZhfwJcsGkD1ZuxzAIvrFHdJ6YNHFTnzhcZ7jzSEMyUJ1bRsuWOsD5CYnhwOVoBEG2Ui3AG3uGKZRcB3zhfTT41QCpTiKqc1d09HWqnsBlA210BvSxO4nAd7u02GzQmrM6bMJTollAkWfxPIscpVeYfoKsyIVE+MmEwwYVYw8peBugedV2RUIHucNJTUMGtlLe1k04DkjGrOfcozSSznxy854wvZoyBJuGxVBK+ns9ELtDJiFTnid7K2Ln0m6n0SCdb0x1/GL2NYKIOi3LcZDvEc5gUxzwKhx1UUBAGV0fGOKpXh6lZsnZiodyso5oV5Ag8U0HVWrQM0JpCXJYvwt/ScoSSl8v0ZOgh77Ve+vJ7OG1UijE0kXzrHSiHAaeosl9ECAwEAAQ=="

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
  password = "P@$$w0rd1678!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033831725123"
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
