
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031748739116"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031748739116"
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
  name                = "acctestpip-230728031748739116"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031748739116"
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
  name                            = "acctestVM-230728031748739116"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd754!"
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
  name                         = "acctest-akcc-230728031748739116"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAlDducRKR/ZmOh4btyxymdO0VIE8ria3FASBXN2RIuu5qyZC4JOpS7GZMc0A1oo2Yq2dOUoOjgd8G9JYLsmcNSbKbFTpW9lx8VIpyrCEvWlu+cQc7l97yL0b1mhE4YpNXjx2UVFTBs7Cl2E1nFhXWPBM2ep0lpAsjvMnXAhsX8ctIOhHc6eTQiaiRad3ZmIBXXr8JLWV3pa07NVMHatz4UYfWlV5+Dx0HwcnMdiB4eFQAqAYrbaL4OprIEEs6VBln0Ot/GpL3Hk4gN9eGMwuU/Yd8VFTpvxChaGVZzmxN6SNd+7XSYORO8bRSpbrVzOhaNiGhLo2IRgD8qr6Q018WoUfGq4PrRtsTtcLPRgmwORnCvWyx7ES3tThXnMA0wGtjG6lPo8n9QTU42TlaweB1L4f4ZTIU0P0qa54w/Xv5R0rMMJeQzhsP7JYIa6V8M0Ley2a8xleLneZosQaQtOUaX6NWPJylU6fNc2oaHDz6QlbQX1KodGSLVMqhXbXLQrLt0GDbMyWM7/7YkPZWNA3xixrrEU7DYO9zC38GS89anmvnIWGM0lfC9S2VmLQx2wAM7bZJa6oC9AiNn+QTXOcg6QXMnFcJCoa7VPWixEt5mf/7cKuxrBfadst2eHxJlxDYh2QzOUqcZw9/RLhChw49ANNPdcJ5hCj/gGBgNowXnFcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd754!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031748739116"
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
