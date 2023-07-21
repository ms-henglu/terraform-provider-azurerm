
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014501479740"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014501479740"
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
  name                = "acctestpip-230721014501479740"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014501479740"
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
  name                            = "acctestVM-230721014501479740"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6926!"
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
  name                         = "acctest-akcc-230721014501479740"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzS0Tuf0Dki1oI72WCFtsMC92aYp606xONS0/H459/jgJJjXNOsUtZN5zO0VTB7DfXfRZCiSk5nzGQB/kWAR0c/Do/uxvomVf6jz5oJvmYBmcFwBlmxApvmKVj4W7+67EefLfZkVCus+KfHyJyQHqRNmJcbZFEzSP3SUU7uJBhVsEkBi6/9qcE64Kl30m+GCmZYUzFY6zUgqMTHMmBr/yp72zPc8RqH0NXFiZq9xOvgORcNNEMtgyqt6kdYTbRg4HeJG9L9R8WDLR5sWU7mh/tHb7CfMCN1RNoNvqUFEeSVAq1Whiocw9UtpVJGezRpHQmnkSmtI9N/V+D4iQ+SXOenZZy8Yj5KQb2RtYs9XIQ0cbSf+eg/GsYOabf88YahKmelOhQvao3e4KKKqXNDVJ/NrX89ukB4Hm2+u6tlTF0oMqa3dLFDVnaqe6rpge4eq6Bi/LXfqYxKXU3NNt2bRBhWsACkPcMFmTIFKEjdbhLRKHdEPkj30LQrULiCDO0KxwnZK1Mv4L1aMLIEfQDyCQgDs2OUkAHiMGGujpeHomaXmpVqBDCezYG2fG0nsUMM7b94Jz0nIB/DFoEs/ZSVWvT694m3R9nTaUVjiiAStmTftFVn30dnFtg5rcAui0vycIKC1Zy274QI5ibSJm0QPPGHtjXfjDLtvzvBaPLFzSD10CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6926!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014501479740"
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
