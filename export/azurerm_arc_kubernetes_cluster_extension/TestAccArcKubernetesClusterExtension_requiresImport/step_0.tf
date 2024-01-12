

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223922967583"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223922967583"
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
  name                = "acctestpip-240112223922967583"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223922967583"
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
  name                            = "acctestVM-240112223922967583"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2564!"
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
  name                         = "acctest-akcc-240112223922967583"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5cK9hb3uTcCSMn7KA96aUzWAlWYjknPZg1Zd+YtKxmkbAIQ1RzFax3aGWGG1q8S0UyPsypDsS/NL27/Eim2oadlc+G+uXuoGp5iWCFL74/OYSQuipqb4qkycgihx9ZeB3tjVqSbyBm9kYWKOetQnWkaVEfmdxGfqMfHcbdw1MYMEES1Bo6K1IjnyvgWsgX2utFKizFWtx8wbO/gC7alc7Jl+muw2DHWN7zsXhgHa88PXwjFu9UwL7ITKxv9HzNx/p74HLIWtg63cDx5LRN6yNtEa0WA5/nJ414iY4VfErBnQWHGtaiL5USQy9/vilEtkbSxyR5ttS/uX0iP/tlGWAfbQtOY57+Jfc5URSdlnVR+sZWy8kQkhZBqqafl+VcjbCV9KvSjB5n+5eZ5YWQEuB1bGoYNqZPLHT7/IWZpJW2Lp0I/tVv4vfq6frzy9OQ1plREM+sB52zb/1TmxC26diNXu+9WwJwisyZhCQyoavELrK0ZGinjzHUTGP2sTz1Qcj842fJH6POQU8Nt0OjnvWtAc3CorTAuwAiqrA7ffov4/1mx9yn1pQPdj9U/51A+bqyNkInc/nxLREr7bSuQZkU1RREmy2lMFNEqsYGRMYEFDAYlhBmNBLQwftT1L+pTpJCVP69tlLeXrHjusocA7TGai+JI1CNeif+nSffJdOBUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2564!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223922967583"
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
  name           = "acctest-kce-240112223922967583"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
