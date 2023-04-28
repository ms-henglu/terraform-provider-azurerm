

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045203348826"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230428045203348826"
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
  name                = "acctestpip-230428045203348826"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230428045203348826"
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
  name                            = "acctestVM-230428045203348826"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1282!"
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
  name                         = "acctest-akcc-230428045203348826"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAlfMN3BLSSOf6mCYvpvYzFduoA/mR3YgfdPXo9SvVxHOyNKm32T1ctQ/o9IDWp66J+w5ZNlCgRwRsNVRFAmD8CPNpWT2/tFoWhS6PHMuz7oRTTNveGd0nNGTiJvCZ6moKSV/XFF6cqrgTq+Hit7OQG3rbo3iKTKII8KFhTENr68uOWUnr3tVJDcIIz4+p2fwcUMFjGbIEeAPFwiXmBPMpjbVTlT2wYjfF02XUuTvHTmZ0KZmeI1vrFmGNg78D94lgOlA0WRdgGCPuVJgSY+1AYgqowTOVW8VAGVt1Cz+rSugiuKtTUGbdI4ylYBwfMzT2EylqMj5CDl2D/lZvqtCn7Fpylamp6c/BT9Bj3mVzS4S90Zqfgjfb8k6CN6SrfaK2DDSXEqaXqkMrR7AckfYTHbhmPZqbgWtc4igwjsnQ6SuJhUAga9Jj3drQS3eLCPrx/UYVghb5sgQcGVxKr1whH0mp0hrHReHfFW4EewoBdtwN9uJeWUI/qKkd9LOUR7IGFh0pF9I5b4V6eGhgNjF+e2TDycakW9vvpeM2e5UthdWU2U/x3nU2L+QZOMug7MWLQLofttiNRgxRk44zfKFOGZR+buKTRGxi88KjNB5e33z5P+QKJyNwcvaqRLGFMyGBJakhH8piZKKhTHK7hwUxd0lBv95h9P+0/M8Vsp35oBUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1282!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230428045203348826"
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
  name           = "acctest-kce-230428045203348826"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
