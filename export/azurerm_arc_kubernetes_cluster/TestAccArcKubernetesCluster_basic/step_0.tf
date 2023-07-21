
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014451773521"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014451773521"
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
  name                = "acctestpip-230721014451773521"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014451773521"
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
  name                            = "acctestVM-230721014451773521"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9587!"
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
  name                         = "acctest-akcc-230721014451773521"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyIUrYpU7x2OM8X9QE5CtlyIhJb9zqFJaCS3+K31wDtBQ+sJlfBOUlRPdyHArhEpVFKXeWBwWPh/wP7u2jMJRa636igbLalOar+ipnSoM/wASMtsBvMEvVY4L+J9uL/4xW7LfiNggylvip4bz6SsCW9yQDaf6IqnrMhhSldhQISxkd21FAvhIfFPMP48oZXHJurLQ+cWLYvVSnu5ndlNiUZ09RAJqBYU9yhzlSuHv+6c4zT+X3wlHYU7YqpHCzQcSOroUtHrLV4jgUinTtcszwjFkZOStik/qWH2QYBOCR6qIAKZ4tDfavvE+he8N4IGU6yaTDas/bTg7PYRyLl17Ts/QGDrijySwHJKyFWkOOk3uYkKq4vlcDS5CJYvV4TCB4eMFFGqb2IAPpbHtmEdR0MVdpFPwhJizBZdkpHc7vS9R2Bk99HkRyXPPcUgnvCAMldNCl63JpPWz+KclIE0Lxx7Lj3wlrpLDLQY09NWui/w7S0m698G15EydtF7EB21+eHmUnVTtPG1yHeFUx/Vs4Uidkupgzo/zxKZAI1IYbvou+j5wqXe4ReI96A6LcXqnhXa5qKZy49z+PyLP5+XbN/vsuSZJULpaqFkLIv20myhOJ3k2LP1U6bJB5U+XsyckXD+whTWpHACvLCuCbrbFq0yZPSRT6f6vbTHlAOKcqJMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9587!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014451773521"
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
