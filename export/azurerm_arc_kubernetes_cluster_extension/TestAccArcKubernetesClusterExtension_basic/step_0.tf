

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122255095939"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122255095939"
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
  name                = "acctestpip-240315122255095939"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122255095939"
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
  name                            = "acctestVM-240315122255095939"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9591!"
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
  name                         = "acctest-akcc-240315122255095939"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxulLu0WmQnDlZ0dg/XsMVBYCPqpZS8t5ZGoSU53Xs9TZvGtRO2fZrBP/nnEv7EjQLvw309cI9QzxG8i7yYxCpgXu7RS3LBKydCySgqEyujIEy2Q9SwhVrXQ3pRqsuq7efYNbT3wdJVfwwBvWrDf8GB4TuojzSRb25CyejfTo2sjTZtD/1/ueDQSFKmksX11y1oVLEKZJ7pji5Zu6/AupPz7YzCkriNh8u1yGmR/+9LHjQnwmjnDzFaNs2PkhrXjoOE4R3l+8JgWzr3I5acT1zxdq8Hm2YEOp/3Oka+XfFzT3AUs4LghDKddNdRrhuuj/lQwXP+ssBv8Z409sO4ae4LU3fHL3dRZ7bpfEKbcsDjErSbfV+nja/kV/5ReNdR2s7YjFZ58pi94WCmeHWqPsj1hEmjncdF9cmmHGbXgLFkkdDoKLRwcCyBj6NEHLuWLsxUH8uaqS4mYIjnNYdz9fcuO3Uq0jCln2DUGwJNLt7cnsCHGmp0S90cXqT7/M4B/chIwge38y6xJIk5dKEbBQiwK2qTuYAby9bsCqCp84HOpOlPkZbw2nQfFxzaPVrQirHroku/6/J/fn4TrxuKYkY3A6+a5f0g947s1xdPOwPsNgNfwb8BPejd/mSOHdmVgXzJvs2Jvpfe+HfnWg/Sc2ivysRyDFBI/6Ow3Bui3lSWUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9591!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122255095939"
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
  name           = "acctest-kce-240315122255095939"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
