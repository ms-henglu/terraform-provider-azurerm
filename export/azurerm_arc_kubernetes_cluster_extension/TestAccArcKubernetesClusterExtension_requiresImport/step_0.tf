

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526084557721865"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230526084557721865"
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
  name                = "acctestpip-230526084557721865"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230526084557721865"
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
  name                            = "acctestVM-230526084557721865"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8688!"
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
  name                         = "acctest-akcc-230526084557721865"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAx0YHzoFhi3uQ5tYNCo9a5l1MLGWwFLy8dJ83JENia/Syw4gs/Ig02QU5Y8Mvs4SrszUYOQdmwx5FsHcETJPbZ4dGoELiCIG0J+y2O0pxeVGZIoeqoAZvITsga4QHmteXR4IyyuyLU7M75H2VbhOA574AUsLqJBQpsEeGEyaxPKcNiWgTWlNrgZkJVxj2qyOtsfAcNVQtLayTiU0KbifUIxJJbWNkqqtfpqM/RRZGfEBNYqiH4jiNs49sZdbt6DqHZ7A6AgjHzUrDCIhR0KePB9WnopyzB7fXrBGq7GAEsLvAl4SodH/kGCA0BQe9SO0j1sL+WkprQwEiKG9o0M3EwII3285/eWDSqbIK+nk2rdNGKVGHdteYYj0s8JHVfo0PyyKhr6/J3Q+CcTeewN326c2v/0csgQzCmyJp1KV65zkj82HENM+eGVhi1mf5h97XXW2OcO42uzK3AY8tcW91RFVWKlPm/Iid2v8fYIKd1A8TWgAIkigTfoeZef7ibP1Im5m/ZJVi/49cjXuRJjBhTa0tUhbKyuOyJ15Vd1BZoumGvkx9JSSCr1oRJirxmrAWRLPWUAjF+djhmStYcgXh9yY42pnmttJO3ES2qpuhaO2otoLUqAAsd/SRdIevS1A+j/0v7o92N4ql+6YoQ3g9brRBZtmcDpfULAhKJtJ8tucCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8688!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230526084557721865"
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
  name           = "acctest-kce-230526084557721865"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
