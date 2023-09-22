
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053559019942"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053559019942"
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
  name                = "acctestpip-230922053559019942"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053559019942"
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
  name                            = "acctestVM-230922053559019942"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3881!"
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
  name                         = "acctest-akcc-230922053559019942"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsMDRCOlrdhsBKLJ0Mnlhi5pLHGpm0cJLQdqW5K+yVosR3MO92hzm6BE7zw01DUe+hE39Rp7Oy4mANgJpXnvwo0W3SrC2CcVqVoNdjCN1SrKkOOXH7xE5XsNeLjf8FnJmRr/1vo4CZFvPob8qY83NWhX9vxHt8+a/LNROmrpW97PH+Mq9wqUS1Kb5cqeOeYIZHoKjzKcFWek2O6x1Bxw1GauU5rf81QIf2YpRCWEWqs3K14AeswPdPpT5u6MW+NIAZmcPdh4T4fjlbnGmyxvbdPXIZ8ycS1IpSPcohbLHwvBilsIe79VWNsDhRILILAY0ZltI98FYV/x7cMq4tmEnW2udVzrR4c03Cy+bCrwQkVnhK5JPMZItKQvlXZeINbqRZDC6hijx/dLqiRB0Klp+K7MnavIs+j+NEZqG4CB9qL+olRQNAdQDVBoZcggPyFpfk26lmZTO+J9H0webPmSGTr3+xlxXzv3PcIu/U8LXV83gRS1DKbykln9qTQYRveq97G/xNJvHUzMwTmCtPenKUYpn7y41dxRXB0KiXr0U06vFPNWHUOqudKZ6v/gojLQ/3UZtjaU8i1BNXaFlcGL0y4J+kpeRslhSIPGwbd7o3JTpDMQOyPc63rtnefSgOuP12sFJRm1yYX6k9TECV5nPG24RTXsU9jnBRtXNjsDO/7kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3881!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053559019942"
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


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-230922053559019942"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
