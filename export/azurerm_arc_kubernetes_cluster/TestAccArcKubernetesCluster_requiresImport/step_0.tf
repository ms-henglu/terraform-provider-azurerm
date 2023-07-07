
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003327824894"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003327824894"
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
  name                = "acctestpip-230707003327824894"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003327824894"
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
  name                            = "acctestVM-230707003327824894"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd943!"
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
  name                         = "acctest-akcc-230707003327824894"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAmNzG+fbtpttMtwCKnoMFSdntHE8Fl4sJ46jmPcn18XalTM4jLsu6JwBWNAevG480T4BH4RZarYLmJX2bEhcfWpYbSk8Ig3MZ2rw63oYAWMsGsPV65+PTK9fqD1Jt+JReoiVfTNI2ryn7/KcPluZlIsXKiLYN45Kod3B8TNDjMACYYJlTSXyV56hgYctbjkcoaGPCwiwJKmChzoz2F0ZQpDGGIZMWIM4ty0e/hVb7zd2ENn+cYHRPS/JW9U2NvbM+bZ7Q9kNSqckT9quQHMKYApNNW1nflNNqkEFah6Clw/t9aaOOFZBUG0HkRK9Lg5s3Tk53YWlvByA05OTXEL+vGgR2nwmCjIsdIaFTg8Qy2rimZlzyrvn1E5DKzKyYc5WdvR6XwjF78vSAKJGPZBX5Z/y+m3ISxnucVwqlDxiy2KOri5Ta+RinKs+ahO0QT1y8blsJYRLtEE5SPEmy0Sll7Ak1ryfiMqjPJDQQJVdyXsUSYyW1h+3KQqgEnksnKun06xnwGCELJ54FnqGrB3MCFpCvTGkB+reolaP5bDGCGB34dKoPPYeYbuV9FTN7HdLyT09SfjvP9Q5cHrDzDh1hbZcyFH5uUcrmuVJ/GXF/Jx4bD0yWgysoY3LOF4ADSMek+eHJ8Il1+3L1oIYbkon6GPSjJbs5XXRo/NqmM53qhsMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd943!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003327824894"
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
