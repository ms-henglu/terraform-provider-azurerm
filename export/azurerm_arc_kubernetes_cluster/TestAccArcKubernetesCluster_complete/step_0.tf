
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003329223987"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003329223987"
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
  name                = "acctestpip-230707003329223987"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003329223987"
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
  name                            = "acctestVM-230707003329223987"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3365!"
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
  name                         = "acctest-akcc-230707003329223987"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsYWbYOfc4BK/r8TYKl6Oys6TTnDsMQ9YxQb8oOFiHklkt2KZvXUYMfnlZkK49TrYKqXKyuykrfdLNut/KdgeqtKjiETI1W9BUGqhHIHj4AB3J828LXquxUbnqd2R7TwMoOhZ8P2qPjy4rrQagLPBCc4D+E8q7YBh0mq+4horDUUgYCo+rO1rW9uOvdrLNF0dC9381kE2L6B8LSoJB/XCiZmaeB8gZ+AteAs8PUALJ8Crp2EVs7LZv2ORlh0iCPUzt+QPRPuYnbORIDzoz0h0QoRRTQanAp/u1jBxm4ZD+UGiUvU4nw9D38XugA2ryjR8nBBS0u+e+191kfT4ifoo88eMOYB18ZQsIA5S88Hfms5qR4IyJ1BaU3toXLGE3tLoXFNZ5/HQOEpUrecAkHYCRl/V1IIL0pN9e07zJxQQfRuvOUEMTUrDP8HYpEQDzkpGnF2JAQZL8dbAopFP89lC+K9+/YFWDgw53TznHEUJpe6Y6qHDhAQ7UaMvr5zE9idB7/fbKoqdhVMFGq20sAuIWluAKyqHX3rL1q4U7Ha92it0gFiwenAqyZrohqe30ompRtwPAdDl2kFgIcXPPozFop4USZTVBe8lBjTGFdjYTxCAck4fnaIkRy2/IZmskE/byEYWCWvckeKDVMhFEPt+ZGS+GvYR+I1kXFrnqmSPkG8CAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3365!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003329223987"
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
