

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033338243029"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033338243029"
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
  name                = "acctestpip-231016033338243029"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033338243029"
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
  name                            = "acctestVM-231016033338243029"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1099!"
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
  name                         = "acctest-akcc-231016033338243029"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA6mJ+/FbGAsefrHOt+6DTrwz4QgF/f6oXpOHCXQPIzVGOPFi7cN3KmD6L3F9tlpS7YnL4LtfK0iPauQNZrRndxIITmo9kybqdOSCDdZB5RVUwPGtEHCSf+l6rdxu+duoHUMOkZTP8GHI6Sa2PRtPEe36BAc5mlQOo1camKEHLXy9ZeEfGk4Nsi2GdC3mV+K1cKl83FLeHIzoubKWlJ0IaXBJu3Cl4q9c18YEZ6j/qASLfcF8uPuB8BYfH2T+gidTOaST1kuSnNeOaZhpDYLPe+qRDtHReUdF4kR01ES2hcmzsvhxlWkDW9+ULVGbQVdll/AvbZJtX/Qor0VLHV9SRdzUEEpm1FF1qPmU1fvaqHos7g0ziX8+QBllaD5gjWNtzulYKd6O3Rdarj2f+HHYlHG8ayWBSuSg3b5BfBM5yHJO5AW9zyT9Qj6Q6Nt5hnTa5UY6ksHzmMWh29e4Z5PcrumGUccT56P0/A+YmfSDh+b7AkWsI0HcipCrr/Dilx6k3ejaMRL8mAnhYwfZHDmhUZSd6/sW2P+X53RvdkcJhMGXiaGbzR7mbF6Sv3So5oB4V4N/PKwYZ8KnqXnrch/Pg2TRUNXyScxked/8zokltrzhefJVuKde3sPkVbpBUPlmQqXWy147WwuJ0JS9wZbhgLIBw/4i5xRWIkNUipnaS9IkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1099!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033338243029"
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
  name           = "acctest-kce-231016033338243029"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
