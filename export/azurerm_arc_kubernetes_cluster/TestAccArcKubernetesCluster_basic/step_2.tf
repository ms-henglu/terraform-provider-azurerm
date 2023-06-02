
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030138535279"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230602030138535279"
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
  name                = "acctestpip-230602030138535279"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230602030138535279"
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
  name                            = "acctestVM-230602030138535279"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1065!"
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
  name                         = "acctest-akcc-230602030138535279"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvxMvyDWjN9ABiuAky//SyCwutRgrolyboNzwkwxV28dl4FiYbjcsubSLGSc7+EqhGoi7LqfPkrPcDUyDBFnDAZQEGlNxOVLF0LiCvPXFWSJctYlhmfLKwdY5OYnPfN9wK3KCk3NT9q+9nWleDlv/uH5V7vu18FmAZmvNAf5U2mNj/TivhXOr8j/u5iaplNH/dPSIzoN1tGiYlYKe0tcQbgQ7pIilnAJQP6rOQx3rqObAyDDayWbCuS9i3t+P/YNETEerR0nHvd4AMy1kk6PIkcOzV88wSj4KGfdnnXAibGu149s+PZ9prYbHzo6zZI42FLOPrn3Gyt9QtHloYbcBa08HqMg6GuJHHabl/E+eZknuADEcaN3o9dimSofteINyihxkenDgsPfq9Sh+3Cvcti0vQt7i3Y3kAm+FWQWCZ7uoc+Zmj97xsidrQG9avNeM25Lth7HZRAv27updKVCkTFV2mjEBAT6PfpbZNrK4LpiEUzBdDyEqgM6llNCbW9YAu8f+3aJmmvFLdlA3LHpulGMTO/e+E66Zmc5wW+8CHT2i1vQEw7+ysge98v0xtiXNnaQ315pSNGrTwSa8bpiwrx0QY1X++0FRZ3ZHQCy653vwDU3Ek7zrp6/oizxbs5xEsQuctjq/6fp83jx6NPn0S1HQFQ4Ig3zirb5UbJNooDkCAwEAAQ=="

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
  password = "P@$$w0rd1065!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230602030138535279"
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
