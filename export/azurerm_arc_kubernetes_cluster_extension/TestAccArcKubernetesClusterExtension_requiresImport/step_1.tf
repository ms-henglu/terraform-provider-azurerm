
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023510236809"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023510236809"
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
  name                = "acctestpip-230818023510236809"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023510236809"
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
  name                            = "acctestVM-230818023510236809"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9703!"
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
  name                         = "acctest-akcc-230818023510236809"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0tGeMU+vaoomLQoZOpbHYmpcvp6pYpWTZ/CAd9oOLqOYMBNoVNxQJIhbhE8eU3dPPb1hXd2PklbnmmSGSRK/N3MdmZ88O9oOCW9IPvfCng7YSpshhDsmag+1iVMRiRHdea7W9zMMhWTOt9x8CVHezSwIQafWNkiGl5zf6PIJ2k+4A40BeTvzpsENRr7q5bIr972o6M7VE7usIvnMn9rBM/eIjl1QYSzZESKhcEt/m5Y7CKWEygrQwstJQV27MpBtNd1IEZ0oLJ71TVOatgvo0+rvZ44KPBTiGB0NHtMDLS4ZKMOxfyNKyGwg9Nw+PYkPwLbeEcu/5cQURFuxppeNRkjAjyuER5z2DcYLM4C184kEPqnBDswCJ2hnlXcLWUS42q//nDQo1OEFQIi9gwpGb7pDzSBRasHzgdGWjJnKVcDus+GDEY2uvnEHSaQwQZ2T0QZOP+CobWrPR7GN+aQXz0KEfkHIfxL8w0YrOh+UQlnZd06vg8WZ/rfsg1+43uNPXuXXjFY4AKF3AGJt97c8yg1bj83ZuVeIM0RvxmlN5F16iAFvmeK797wSbd8e0YprtNbvrfNbxcJHILsdtxpHDgakcQjLx+qoEEpx6Y/akP/p63tZP7b+urGwMMdRX62g20P4wrv8cBpU0UCiWBDltZsslsGC94+0DbrCH3jK/5sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9703!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023510236809"
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
  name           = "acctest-kce-230818023510236809"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
