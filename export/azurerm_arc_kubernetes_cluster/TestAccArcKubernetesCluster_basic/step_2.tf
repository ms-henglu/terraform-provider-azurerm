
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040528641275"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040528641275"
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
  name                = "acctestpip-231020040528641275"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040528641275"
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
  name                            = "acctestVM-231020040528641275"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5244!"
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
  name                         = "acctest-akcc-231020040528641275"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwSClfbF1DsutSDzcNXgEEVpLwOqq6X+1Jh0Lnx3pKMel6/0L17I+aDJlLIgFsFS3wfU5sgJ7GQadJjBxFtShDPoeNOTHu48pmG1pAj5KkZ648LZU4hgkKb59Cvi89610c01Ng6oih/rG0S3YbLATHWiobPK9p5KXWZkcd9N16mUtgmuTItIyaIyQHRPZ/yjoFgm98jp8GkB6aExAa9n0jB6mKaHyY6dwflirUihSmFmMdLS1yVnR3ti0liH9ZX+qLnkOx7fmVBANIvncZJ1i1IRGzpmETmZRdexvdNq8EmTPg64OjK6XBtF1vK1YCMhFmmI2n+2YgnvsS5/96j8kNHgdIpP+ANjcKl9vJmIMyT3/aVaZf3Gt/XuOyjMXcgb+68ime66BxKxBUOu8Am+YlqWDtlFJ0Duc5CNY3BSh1rTqD+mV+/3zUgGzA6XRoYanHwsUXV31eauff/N9VrDhi9oLpS26cQelDnQjWNY+0eBn7H6q4e9NWs802NDNMBts5x+C0FZtCXoxhGN/zOOhFc3EpEZVaY//r9QikS/6cG3o7AfSfmY/EwIBmo1++0fgQWZDfgkVxDinw+auki4t9ENqxPL0djA6Z5dwvHTZTP+6knb/k/TCAKNtuU/d8eVN/5EPtTt+WZcZiw5jhGzentBkey8P8f/624BsV8hYMF8CAwEAAQ=="

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
  password = "P@$$w0rd5244!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040528641275"
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
