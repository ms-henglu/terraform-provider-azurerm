

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071320452050"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071320452050"
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
  name                = "acctestpip-230613071320452050"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071320452050"
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
  name                            = "acctestVM-230613071320452050"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9715!"
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
  name                         = "acctest-akcc-230613071320452050"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxrT/cGECZQqTtNAUiyCdZCHGxYOTYwikWbqHg3o1B2E4nb7fNtHP8ShQxgZ2RILfogzCBqt7rTQNWLHFfyiKTy7xpMzSaRL1w+2jALvyQmy8y0xGA/SUeerLDM8Lcn5cezSDRKiJ1xtlGsIo4CQ/2nbBUoq5wDsf1rsVsOAo+M673oWiHiSc1sW+ErnT/PeBqj4b9Fa/wSkFIIb1KWeGSDEjcmQ0iTtAa9I29kE8/Qgz2Wagy4sOlRhmWZd7PlIIz15+WitzOuHREJQR/S9HkE82hVhAiknabugEp1fzSK75FbbiJW/oh4L+3FLgDgro6EnA0huLJryoOpFpR8TbCrQE9yVMmlHm3oELVLNCcsZbIDgL4wAp/Dm5yo8sM1u0mImzz4u6//iGjlBHL2GSzYSPWTJX9Lws8VKJdoZIhvx9g3oD0tDCwGoVxTURbnzAkvvKgLVD4X+iIlOJzsC9863RUgDuqgTPc9jBLqzb21Dn4tpBW1LVjDzBHHpQyfPqx99BEtSLKxOFT8CbSnXK8PnEYHSwnxTSSIWu5UL2pjMTG8QdS11heYMlpcBDot53YUMB4mld3wPuS70nPGASLrevW6JDbBKvKPaldEhUOtUvSUsSvNP4Hh8SUa5SJN6O/ie7L3Be4oaQ/fshXakbmDgpv6VFNF8VU7e3de0MZ3kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9715!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071320452050"
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
  name           = "acctest-kce-230613071320452050"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
