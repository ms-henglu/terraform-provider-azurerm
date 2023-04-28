

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045204844512"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230428045204844512"
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
  name                = "acctestpip-230428045204844512"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230428045204844512"
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
  name                            = "acctestVM-230428045204844512"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8756!"
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
  name                         = "acctest-akcc-230428045204844512"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvh3FKQjn3UtY3Cqcy+M1bPRtTORWUAOdJmx300Y8Q8e6kiIUDpTJyCrQUwoyDqFRGsf3driZiHUokWJDdVgytjZogs0jM1wQ9tUX6Go7ecQMF6jKS+EWDOt9qFow9ZJBZX3ukioj408fUuq6it64CSA2MIx9awfgyHldPZ2eM2H7P0umjMzcDiBFXpsBRAJQoylGhlLUH5kQvmRk5r2aQ3rQMZTxZWkBbgcg+AS0zHKpMSzrCDhH8a+FTRvubNODKVhhnmT6FCOptc8MRyYL+x/y3NO/4aOZ58GSNETL+KT/5+T+bfT3O1ZDryjSGGd0YNPfv6C5A4wnkGuJN+InV3qSzSV2/0IlTj7rFxLend/cTRq7kdgQUDXcN5SjFGhUmYm6RTXPsHNKFSGhoyi6WTPf+MVvB558TDB6MPuRqhs+gretU02RlIEgTA9da/n2NqsUXBrvQbI7tU2JRe5XyMjBSfAhxaB1aj0MIPBGWYEU6vPhCSnbZbZq65T22B9POP8zdmTSb5Sm1Vs9p60usc5jOFuEVJLS6O513hJSMxhv/l4T33u80CJ8w7npLklQvuhYcRPKJTgtN6yX479gsvTJhYdeJCDanxR3KotEYm0/LadgZR2VSUmGcUdJ1gL4IntkTiV1bnxW3gcH/pCyhNlaPQDIU0nN5FC0ml0T0SMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8756!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230428045204844512"
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
  name           = "acctest-kce-230428045204844512"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
