

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003420448452"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512003420448452"
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
  name                = "acctestpip-230512003420448452"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512003420448452"
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
  name                            = "acctestVM-230512003420448452"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3516!"
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
  name                         = "acctest-akcc-230512003420448452"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwRxvrlFX74cQnyZ+WqD9wumrXJYdm+Jsj//nm5E1bp3y9RpD4APCYINuLBFNvuaVANneM3CP3yQYHCoPVavcEkAKqpMHwBgS67fjZnQ9IH7rt0gmnCIrDEeJrZB8cZ57iDhXfVrMU5mgNCmnOqooRT4ZuGwIfire7CsSQCx8QCPm84Lds8tkBpXvDuRtA2nPQi657Vjgj297mhN/EAeOttRA8u/7rZd/VrdcYdzu7KRqSUcxPSDAsHF/ET9zKTtouHfoKrTWIwtYkm/RgPBN9FTeu70SC3E9LTGxGGCdYJ0ogOv2I4ev9lZ4A6neR6MaJt8NsfYTBzFU58lxMkMbGJ29lJQXKTiS1cY+lgbtG7KPIe8FzsHF3lYJYj+q1zxS0KFwOztvE4v1bFsp/k+scNrh3M+lduxYx52JQfmPJXsiD1ExhjFGpRb7fDaEA7LsiXv1Kmfmubrlnnyjd/65dAH5DuWlega7cyfpmayx6VYE1HqaOPfKW7HQ1pHLKhHB3Wp6112k8mmnchVO3udtPV34Nf5+NjSEN3gzZZ1CoJH5nRVk5TObA2kBlFszN0c692kDJv+4e1NN57jhgBcJgcGis3IYno7S2eP1fDyyeJwpO6VtZZQJ4BYwnsHB74e9CPIdyBservzVYDPvrkgH+Otm9M2YO4ewFRC/4ji+z40CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3516!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512003420448452"
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
  name           = "acctest-kce-230512003420448452"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
