

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505045833157294"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230505045833157294"
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
  name                = "acctestpip-230505045833157294"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230505045833157294"
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
  name                            = "acctestVM-230505045833157294"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9699!"
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
  name                         = "acctest-akcc-230505045833157294"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvmr8jlRvYgLyaRPwVMfpOSJBDFFT8sRTmztF6pRSghOppG8kiCHNGbqbdgC8n7Jz0FA4igzuM4n/dlHUTCzKzW9UFjEeZWrZ2qcMbEg7YF8vlQCiO2rCQQbzwrzP/M6fnoivT3kAvtDVkKOY236sBfpMTAPbVoPtBI8Ot7oduoWfY3Sxj+oiZhRUEduzBRlTa1G50HgMgJouP5aOBybuUt6ZDZj9a0rXX+uBWAiBnL/E/I5mR0+LQZ0cNVIvPGvT6DG8grIAVbBluaNkIOFyzKoOQbUGGucJGQ1uNllTpi9ioj0smJkfa5Ou/QpPoxbTCec36+qjA8uXwYdeTpQwa5nt3iqEfXTIlKi5yOuO/4naoYJLSfX1hLIGyYJBp5w0vu72IL/Jqws0YsFUIQpOv4eNGDiDGa/48N5FBMJK81YmY+6LOdiPNU2hC6795JiKsafNjz2rtFSsZ7E5xLjhSGohQC/yHG92d0Uqjuo5KYll6SDYzU/WO15E2tE54rQgnhGBHDLFTFk1y+9qrx46UZl0H0bIgMGimdWcE+5XFtvOYLJ2avKZ3zTh6V/usNvpvmjnmpZn3sd7QT85X8+LLOHgDVw7Ns8Nau71QRWAQNQ9UjYtVE+kkMk5ilHm6W3W6s02ohny6EgrnydmTKUqOBB56+7USL+0GRYPPLbBkQ8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9699!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230505045833157294"
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
  name           = "acctest-kce-230505045833157294"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
