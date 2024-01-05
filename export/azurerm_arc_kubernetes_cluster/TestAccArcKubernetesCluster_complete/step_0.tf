
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063255824314"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063255824314"
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
  name                = "acctestpip-240105063255824314"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063255824314"
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
  name                            = "acctestVM-240105063255824314"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3395!"
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
  name                         = "acctest-akcc-240105063255824314"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAr+94aV733gVMp3B3saaDscUduEVDUmRmvD2ezU7p3DXhmBliYauRs9qaJZFMC3rXfvnbSYc9ARdQUQ0vcWaq6zb2sTL5aB/45y1jYDHNTP0uRK1UtvHcgAKKXpYukHOgp6CAqLD6prCnWSb+UvP0a+7vayPRv8C4EFu/PFWJ73QZ1h6cjSi+9hlr8LHCAK0yP05rN7Ack/nBWpSoFJLR1tv72PwYtnyvSqM3Ecc92Wy322yIBnPJcsuYaGrVdFtqxP5xC03RxGW9xpQHdUtY2Hf+wzpYY06BJuaj6zButXkX+KA0oAGMex+L11z0ydXftWOvAEOOafplc+vVpZAhi2TDnZUFoFGya5+Tjl27DVvzksSysB/0S0AiJ5BsxZaxXP1aXkHwUwe4JAZ2Dlfe/a2MJr4efTH5zID25S4XIHWAdll8HzVMwI80+CinaSpHxdrGDY4H1i2oqRfmPVlRX/g7In5Kmin0vcAqgL9NeH8H7Dv0OJNTXT5s3usHOaJQDrsuI2VVk2asB2lHsO68hh0pK6OskJj4FZn+EvFGflr9DcFtJpANJT8UWAbJ3RjyBdlRsP/99sUCz3EIkDmu8Ed51HqSyjDBYnARYKPuimQt+6TzXJOf10u7Ekw6VwO0o+OgsIWyGCQ2JQ82h2E0+aCHAMTugXlTOyMhjIkuQ+8CAwEAAQ=="

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
  password = "P@$$w0rd3395!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063255824314"
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
