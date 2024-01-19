
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024500108954"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024500108954"
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
  name                = "acctestpip-240119024500108954"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024500108954"
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
  name                            = "acctestVM-240119024500108954"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5248!"
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
  name                         = "acctest-akcc-240119024500108954"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxvr5ukzi1jal/k9aPovyGI7ik/j17Zax/U7zNaPNHXxkmqaMciRY3mqVCAQ1/vRzvkNdYrrgBmbeEuOGctxqDzIFfpFl3n0VP763me7YsM6U+Z+43eZxo/qQqkMHpXkz62361uN7DEriH8H6uW6yMY4jrto/Q7fgsQYNFtq1ggqxdRT6jzU86E6ZeLm1D0MEYhqMFm8IErSPznYi6kLLU5wSThLA3Mgd2D5FH93BTtAH7gIE1zOWahtp58w2zWKIw/dYTZIv+XvfIwy8MrndjrKNNoWPju+cG3yvSQLKmpuQC+ZNJZhltg1W5jT8Wy4bp54fQhzu7dr/JOsTREzOBrCFLFy16b1j7PlC+9eHswyGg+a6tppm9O0nCLkJGBAZsxIVnJ61QNGj/ItvoF/KrnqDmu/g9/FoYCyeHjrOq0QzL1VeKHkKxUw1drwfyHaMZ9t9tkVhL/awUcQBHnSUMBijXU2YiZ63d1Jwqb6SKkMRZJKpmJR2CVdhESLIxiL1QTO4pdKAyJ4kwnSS+cjnjcLD18VF72xRxFLix/rfKyEzpl/MOpDuTt3xKjX3y/KIbIKuHVxkjaWVp2imQ6PnOTUX0cPz6Q918/8SSZUOfTPDkhCYhk0T0doLPxRadXlhutFMKLz5VWUeodAJMvDtjr3hZeh5bOASYap+1qBId10CAwEAAQ=="

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
  password = "P@$$w0rd5248!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024500108954"
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
