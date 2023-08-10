
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142938949063"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142938949063"
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
  name                = "acctestpip-230810142938949063"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142938949063"
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
  name                            = "acctestVM-230810142938949063"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9011!"
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
  name                         = "acctest-akcc-230810142938949063"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArIvbgtqRDUzhWFil2r5luKGScIPzR/6U2QS7ybNpekCBhA/eggdu9xFEn26hgSp0XkvcFxeaknRXqzR+u0F/fgTXD1qj/bekkllfqNc1N9D2V0X7ffb1udzwNoF5IMatVJOBSaT3qhBitpDBNKxI55yk9kBKKIusqOLG8JxIca38Oozv19JeoAPp8GQZ9PF7aH4zFNY7HqMxVj+Coz83UpkBQ4t1nwkovVcG9+m0gBrbwgJzlYpTV60dRiU1ZHQoAWryg9QWPm/0JeTe29VlU/wiX/soBzsSAyyj8jLHr003DCK1f7sgN0Ve82xFqLW4jijRMhKri+3RyvpW68M+3gk1vVlckbJv5N/9wammyZiW61bMN/nyHNR/OfVplCvhUe05lCoPi1D+Djt9cc6V+LxZlgWa+pMcuRu/q/Off4JPmWo16iHVvjzc7Wv+JIuf86USYz/Gv7N+MM3Tf+TU/kudfe4EG/HYEOFc+I0l5nrzjGujZFP1tYuo9X2xlUYwenQHUsTO/kyaZX4YpNEnl+RjNJQ3ZfOobQ3UzzLDflIG/80oU1o3S1GZaunQvObkGz0n6I1o3m5Njx4h3kKfWdH2b5Vm2maCz7Igxuu3wtb3waBZGTgwj6E4SYfiLNgQMx04I2RS2yPbYLXCHEoLFguMd9uU7hsAPU119dYckEkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9011!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142938949063"
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


resource "azurerm_arc_kubernetes_cluster" "import" {
  name                         = azurerm_arc_kubernetes_cluster.test.name
  resource_group_name          = azurerm_arc_kubernetes_cluster.test.resource_group_name
  location                     = azurerm_arc_kubernetes_cluster.test.location
  agent_public_key_certificate = azurerm_arc_kubernetes_cluster.test.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }
}
