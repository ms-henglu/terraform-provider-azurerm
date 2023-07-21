
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011141579183"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011141579183"
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
  name                = "acctestpip-230721011141579183"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011141579183"
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
  name                            = "acctestVM-230721011141579183"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6689!"
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
  name                         = "acctest-akcc-230721011141579183"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvA3HGsHYKMxdAS8ZKEbaUDhqH59SltsZ0XUaHGUYqQxEjFMO4VrU2Dyznb8EoF6i6gko3RdhDwVi+sVlH4f6vaV9kHmlRjLYDFcwxBQjLpMzrE/5yX6WejWPKwJotIYl9ui4Qvyrg2qJ8DEdLHlQhCnumA7ptPWd63HihXsAnaJGhNQu8kOJZKV/CLfUhZMg7fpsNZlEfwQLrm2/KjFS0R8kpWUaA8Uabfvoth6Zff0adrn1MvC9c85XIIBu5EaFPxeMX3Si+xDnl39cOUKo9LV7Gh1pnSNCYJlP6sUuEcThwvp1Q1Fh5ZdICaAXKSwyrn2dR8EcJMuhYkUEKq2g9rzoEcaJTo1bl2VLog5h1Wk7Vnp9z774XMS3V1NjBl573uZ4aXI00CxZvtSBqxh/8l727JGPQkjBfHFlCoo+Lb559PRv4A2ap2BinZwkGHQqkY/mskyNPa/g96zAztFewaPa+jzFyPROLwQuXAD6HY95Shtv4YkdoNSDWKGLmgJTbrR2BTaJRuEXY8cF88O6rJDHTn7ortZHFGUeSe4bvBN37Z2w+SLjbP0t3xF/3+BZdzfsjmSMZsaWEU7BNjlFieFmSetxImOvagcj2MgEk8m2Ht3FtMCPFQD04MHrRaFbZV+sVJ/14z4yQoXQcGz64tw/3zLjXOXtveZBqr/s5ysCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6689!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011141579183"
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
