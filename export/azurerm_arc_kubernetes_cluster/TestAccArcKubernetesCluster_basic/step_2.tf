
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421021651671685"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230421021651671685"
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
  name                = "acctestpip-230421021651671685"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230421021651671685"
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
  name                            = "acctestVM-230421021651671685"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9557!"
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
  name                         = "acctest-akcc-230421021651671685"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAn8pQAWyRXRSgUY4Jmmz8PVS22DGCo2OLZcWrbEusJX+FXd456jjAGBI9r2+RRiuub+bICjOsdZPR2HtwNrWoNNQXpRnMd2RhxMIRWT1rdSvuP/lQans7CeS1/3p6DL/n1CLXBYSqhAsdVZLNLUXpW9X+dwF49SsfZXP8CTsQVh4N0335CjiCKjjEBpeFcEUsANakbjlI8KcCq0pRD3S76flLhjTIodR8yQWOPyjVEZhXXwZwv+7krtQ3ohRUcpGyD4FjisNnVWjcloJMQW49P+D0qAEK25PuPAktMvwofpsijiVDKLo+oI19lFP2oSDpJ2UVbQRP6KeS+mgrxYjJGhrmUOjize89kZsbDioFqiWjsY/Ve4dZmjvKyLCCh15IM6kbKTmVO3AXptGwgDXe6HaPKMv+0frsYHYrMYRbEUp8pZBOIo53lTIW1qIS/EXd3T75Ev5cpqkKKKm32S8gYB6PoQKer15iDCjQDYkE1Bir+rEmE+uvFcUvIfaFyYELvkHWJ+UkvhLF01FlRlYwgS+Od0pOyCnyXZ4dKPy7NCaKZn5peZwn7rLKkhiWQJx82o25YBB7hgyWLhWVdNA20LTmX/TtlgD+OE2sU7HMkI4qpNHBzQi0peeXfjlxNeCusejRIQBDChPLuqj987B/QlIDTqzos1M2u4BHc4AYAEECAwEAAQ=="

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
  password = "P@$$w0rd9557!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230421021651671685"
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
