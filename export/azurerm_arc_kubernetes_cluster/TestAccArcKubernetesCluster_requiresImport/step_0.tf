
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024455444114"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024455444114"
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
  name                = "acctestpip-240119024455444114"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024455444114"
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
  name                            = "acctestVM-240119024455444114"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8315!"
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
  name                         = "acctest-akcc-240119024455444114"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1saOlP4iVpc/UtkyrhAcXGQBfoDFEWQI63QYaL9lzF+1jFCdqMbT2VzUn6wxt5WuH7sW6uHfNkldACT8mIBQ/3kmIZKPHjwL2k6BKm/hwo2f8dyoEt13bJ0zHlj03/Pfrt+yKaKNnoIjREo5lGFDCmVlwO6nLmWz291lHpnCTJHMmA3O8h1GC1nIa0NiaJkOnQ9aNNG7X9wjmLnknnRQkpjGB0dJ0v49lzmzQNbyiDmnBLGXyBrHoFFoXLbSJ1LIlTIomO2VdZkgqSxL5V8gElUmRyjfiximsSbtGA+9ZmZLxeOrZ3SI4WzThUOGIjaUPld5ztPObBvXhS/MYrdR6elhYzfDXEI9Y4KOFiPRl1jXxNzzhLaIl+sIeud/I/0nXiWN8ber13pbjmbqpYt+s4lgHOJHui/2Szl1yuySFzd/HrWinD8immXXGzYM0lU3Q8/uEIDA4STbU0mM44XOn3Pc6YckKHnBKlbagcmYVTCfh9TfUFMAHMisAirTidhvf4ffXPez89yYS9m6Zd24qbqT8VcwL74TF2CJU332vvf3RtqkreLhG8xxNBfC5rXdKY5PV04cAQ7WBiexJBz69BTYxuMXXQzt0RDqkQ001EmPB5Qn+VQgLH5fomHnjNRxEt5ywLwjdUwGb9OvfyvC1j5bV5+rAuuYfr0cLsaVhQ0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8315!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024455444114"
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
