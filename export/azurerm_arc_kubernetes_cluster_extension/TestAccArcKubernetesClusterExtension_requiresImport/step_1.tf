
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074155191149"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230519074155191149"
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
  name                = "acctestpip-230519074155191149"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230519074155191149"
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
  name                            = "acctestVM-230519074155191149"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4699!"
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
  name                         = "acctest-akcc-230519074155191149"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2MXJkdntoLfGPISyQIBdbNrgXZQ/syKmRPws4XLjt4LfeXfunlvsDpu6/d961+roIBsmnaE6X77jCU6hxuLIYQEZter1n+qdZV0oXmfWaYMNhVphLQlZF5V6smc/bDz42G+m7uRlaoqu+CMFSnJyuqfqwAjTU0E2GBCTLYmraiXjRG9C9RWXUZnKja44BHPSh+d2o50eMCqUI+R+aYwvVfksiwV5xmVp8ItLnO9GoUASJAkgtNIFtQy6WL6l0xyYiYXVjJ+DbaTINxR1kDNfMASWpFoLi8OzR86b3zc1vy+IRSNE3jI5W8KcCuIxPqXUi9qY2iYESNt/1UYLzwbEhN2t6RL59f01VtfwTBLa+yOVvvZm9idvmJXPfjV9ZctCJwebhphwIDsg1e8BVt3lVVlOeQ0HKcTTtrzVyHXKLub/UM4OuQjInrtK/UUqgEIJiNLV/jWkKfudAaxsKCt/1GKN9mgwChjTtazacwfk3aV2tNhP4I+ameOEPxl4EyUFhp7fNMEAzBFWsgk4L8OQsYs/uSto053g7P4bvqq0FomVqL5fkI5769Ev/m9JDQJaHDHJlM3xuZa54d+1Tp9EvHxUip1yt14jhQwTShddOcKaTfA/+stVNynzAGr4BY0Uu0/GJf+nW9HX7W59JWsaCoMmE3vrcU6vbpACnZgJXIECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4699!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230519074155191149"
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
  name           = "acctest-kce-230519074155191149"
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
