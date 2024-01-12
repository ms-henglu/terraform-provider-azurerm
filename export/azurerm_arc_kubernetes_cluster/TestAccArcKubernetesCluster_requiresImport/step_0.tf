
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223933709424"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223933709424"
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
  name                = "acctestpip-240112223933709424"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223933709424"
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
  name                            = "acctestVM-240112223933709424"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5297!"
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
  name                         = "acctest-akcc-240112223933709424"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAr0866eTwHzO2Astpz6v6lr+Gi943QRobsg21l95QjbHj8KdPOhX4KA3dnc5EULgBqwpROpAbd4p4rZTGdKUtb610EiDJDJTS3DGNNfHm6iiBc/KWRgMLt5SavcZ2yfQ2UKLrW7JeFOmifA/NA3zSYLaYglOfiqOsuI6xasINV4BO2eEktk7Lku613hXzvvkibwRdxSKTJmYLJCagfuZ5lQMt2cRxYoXT7WhqyPLmtiUQKm2rlKX5ECqMK3siJqobWlViJmyRdndD0YPc5b0EK10upGpr67fbTBmB7LtyNWk5SoJiq9NcyYGc/sjuWp/s7J3lFjOkUlHXR01JuVImCr0GUkqzfZaYN3yyJygWsjdOiUMphblnC/LXFJBWNfwCsvHDiPnUyiPlCj5No0qjWbZGwkLXLK1C8j7jQ8F9nQddIkcAzIFwU74STbVRKWPPvc4+++7KFAb8dAojYlDdQIyp57H/h+ENyZpsm6h3fJ575+VOa9BDS6+IdAiZs1w3du04SvNYDumZo2TTAbttnoOZx4LHk0UQvRaeDyYa/u2OQhFoLcLWg+MYNR2F/RB8IJGvMl3OhWURh7JHKsn6i8njl61g6QaR1Dbwud8p0Nbn7568y/E9Z6D+RWW0VHf6bhdsLoNWc3Og8amQLh38Wfipi7FsO8WET8tJXuB+J7ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5297!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223933709424"
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
