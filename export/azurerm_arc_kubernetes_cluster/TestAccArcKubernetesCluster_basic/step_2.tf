
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005949705139"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707005949705139"
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
  name                = "acctestpip-230707005949705139"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707005949705139"
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
  name                            = "acctestVM-230707005949705139"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5825!"
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
  name                         = "acctest-akcc-230707005949705139"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtwzYeiTxLEuaGCd8yktSvWKZMJ/7skJlpxz2NzLnIvMl2aAWidk9qBfcSR3sPgBzDtlDf+5h6Zmm6wbDy9evn7HWprcnKME7uk/toyjWtQeMxsetxLjIR0y8c1rogQOe3U2HzVxG9OBhfzG89/btxbsNsU3oot/bcCvyaxPDHcCUjkA3Lhd/2vb3pxpjUZRT/LblI3Y0fRZ7+MUNw8vo24Iro0AuvRkZU0hKzQBJoJDP/Hi1x7sC0HUcrDMYADspEVdY9fGlmMAPIBryjFsoPxxZCTy9ulXUSx6CE6B89Smb7GRZ5KRxVWl8dD8fFLchQJ0Ax4Z3F/MnyN7NcvW4k5ZXoAUHnrped1RIiJi2/HppzT5xRRr6AapDspN88FmAXo2H2m59SEwoHE5fnAQJIO4y4V2754RCKt0zvzXfY4mSTh6diwixNGjwaDzejtanieQbFIAx2eeN65IumIedCUkswUTJY618lsJTNGafffSpBGEJsE0M3ybZ3csdPewc07CqQPzY2THZ2wAQrD1ZWPjkIhfx4pdXUrDX5yRpaZ9WG7sfW7XQYPk7V6WHRvGk/8gDmYs2DNuWPXxpf7cMDgvO/UP5WZvLtM/sRM0pDYL6IFBb68bm1nHZbSVwqeZgv4sTh3ub+lbdbowAno8vqYnK2qkXdhqDg9W7OiIvX40CAwEAAQ=="

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
  password = "P@$$w0rd5825!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707005949705139"
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
