

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071218174404"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071218174404"
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
  name                = "acctestpip-231218071218174404"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071218174404"
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
  name                            = "acctestVM-231218071218174404"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8464!"
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
  name                         = "acctest-akcc-231218071218174404"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxLHI6jYb+QHTCGffUTuANW9chhkCbbV2Peu446t3HOjY3EAw3zioiDe1lpwdIxuU345Pf1uXRBAbLdb7ycCqwjWOpqpL3NUzbyvtjKM+9BT/Hs+usnzz3yQSmyuMGYu6UspS+4k1sGkQUFHRoUHuGs82okL5DJd3Je//XQJgyk3p43e/JD3HHnkXoASikRTj2I/cpGrK/EEn4ElePIWy1E4Kdj+V6PGz0P6Hzs4K/hSmdzKJsYnvrkLMLqmlOrogZK4E3oiu3N7FwGskAJ04r0//ctducM+vBEsBYKXHVHdz4UKuOQXzbH9UBM2FCPbg233+0yo/ODNa7fnFkhTunOp5vkA5oQbSidvUGcO1vamU1EGG1HVgXhp2ow7xFtZfv1x+CHkc2DEQSD3prEk4akBX22L8O9oX7Mi8k5/IG13244UepJUI3MiizkP0KBPaZi8UAVNvvaIeyZKAvqx3jGIB6IoFExpTCWHCvWYsdnBrlxqCCuQZnRwvwYo5zdF8YUBhrTg2StWq/E+KtRK2mTIJhNNm5hCAYTC2rbS9Cd8PFxOjSpeLnUn3M7/gIYYR8K/T3Tfn6GAWlzMtnugdGcG/bULMq9pw9swMRpZf4xS68YrO5vHvt1lYka1vpesS2jUN7Xww1E69IuQIDNyIrJr6Ht4QPWZ2f9tP+tChQM8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8464!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071218174404"
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
  name           = "acctest-kce-231218071218174404"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
