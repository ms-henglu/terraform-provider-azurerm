

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023504282856"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023504282856"
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
  name                = "acctestpip-230818023504282856"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023504282856"
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
  name                            = "acctestVM-230818023504282856"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6786!"
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
  name                         = "acctest-akcc-230818023504282856"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxoXmnw+8eplQw+uy0ogvehASpn+POJw0KJDMN8Nxa3nwnEBGtOZhdtEHghQ9YAUHYWXiVR17wFzS56Q6klFdOS8uLuXStwOQ6efHRWMAl1JiolJZWAUEbAR7/wFk1Vr7YN9cE9ABP8DMT3bMvvtVHheQB1HWuT1AKI5TBIuRauXrNhOfwK00qZm06zYmrGtxr2icny4w/qYP1xbOvgEHooW55i3uc43Go1OrKle1rAP0kSXImPPMtPZDzwAsgd8Skla7pI42Ky7wTwhomWUsK5zkXpfSqQVai4peb8J2VJn4R32WG+x6d75Snp2WdDJWuuB/klp/OMSvIfGqlhPuMteZlaQZjimVH0mkL7lDAbdJI69B7nICPVRPnsvITIL5RjD8AMcnBiE6+cu0dFUOwljOMqKduy6te6Yd0Xs0y+yTasDGLrwRVdzgL+qCY5Y8rioE12x/6v5PjhU/WnFI8hgjtssNVhuk9lvyXc+Qcv81ByU8yOKMw8ythmGje3paHX5GVkg1R9gwK6iMO7WE+64sOP5whqUdl46HSDGQGa75V3hCdygq1DS7L63G592P6tYg8Na2gIIr/bc0o4ZA2/Nnj0V7uTsB4j1bOBYF/L++BpWfoEBVwrn54h3BWxXZVfQAVPbUczQqiji9Eg6vUhArrCZNiRYj58M3880fLJkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6786!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023504282856"
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
  name           = "acctest-kce-230818023504282856"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
