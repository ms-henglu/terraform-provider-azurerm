
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030140944026"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230602030140944026"
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
  name                = "acctestpip-230602030140944026"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230602030140944026"
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
  name                            = "acctestVM-230602030140944026"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4667!"
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
  name                         = "acctest-akcc-230602030140944026"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqyM3lAao4GPfN2CcSilQMFaOsDtuLF6av9+aYD0kHjuDeURi8EW2tBAvk25ptvNyLLxJB7G0BYywa5cujK9jYJjS5Z0cddBQD9GEuJqCmEjdr5jfa/9JZv1nbGhLYRIwkiV8U98fjAu7/rvEW4pKVFZoUUk8V3wpt/GvdNKBoNv3ywv4UmsyWZimsrUn+IKiApZbFs3MoaE1SK6OK1+64tT4eYR/7JUK9Xfg4k2P72fvOuftYKzNoYBweS5Z/8aRiCn2y/TkwgIh9MSJxbg77ZECYAXPhNchly4ffygmUKfZCyetoci2GvHPHIt+QN2+02NXWQ96mSnFP/w2AzLn798np3TcFSbuXpYqcUk9RIpdERzroXY99e45xeH/f0u/J2/rXvg/AkH6VuyAuyC8p1KDM/nRSMDLtr2eiCrK+RafpsZbCR2lxyvutPnbR0HKtuLrKU8/OnzipakWh9MG6A1ZcHnARg4SrFZzmVPqyDd4UNA0cXhLDQcEuy096ddmR77/8lnndTGwYofL1cRWgjSrwT07emZkmfmszlM0zg//Pt+Al7hUuyDCpf+Bc86ZNDg7GI8tqm+9xnF5DnKGGg7s+CdvK5rLlBEwKtDbGeM3/KqOF2gU4YDEXSXXiy1EHsaQz8UL6eAGFE73JBmibKafgjrpIglkGJsj3W4/hikCAwEAAQ=="

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
  password = "P@$$w0rd4667!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230602030140944026"
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
