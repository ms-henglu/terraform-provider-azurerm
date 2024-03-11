
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031329891779"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031329891779"
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
  name                = "acctestpip-240311031329891779"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031329891779"
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
  name                            = "acctestVM-240311031329891779"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6159!"
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
  name                         = "acctest-akcc-240311031329891779"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAlvz6DfQO/f4G5K0T+IZ2ev2LQEy77xpz18xa392qdx5W5tHPd1eyqyzBst5TjBfSQKadDagHweL63zuwXZu42JwfTQZAzH2m61vZIuBmWSyEAWRjCjIukRKSrR+JDvV2fH7kHxfXMfKaOErDyGZcmY/qALSu7o41/uBjAjodV4/rRL14X0Gw3w5xME1j7haNvbdYLJ2OTYiqQTqLTLqNHtOTUnnOWAx9mym0d8VGzPSeU6bkFwTb/Js1riPtSWCBpSydvpPvmHLdPx6LPHaM/zXhI5kF6cMIANHe9q7v4uNdDW+kKWZbfj7jVwSWoCtxBFqbJxHJG6q91Xfh7v6h14ZyoSom2NkvZLyHgvOx78ld5ANVez1UV8Du2sBntG+zkCsyg2AmAt36LLVvOt6P3EKiLI3ig1B/U3eWRB26l7HTTNrlJVNaFS6HkUi5lAwWlIllzI7PXE9bXY25tnHKeIuU9msps8Qa+NgriGi2S0mrrZjhNPxNcfKCp0T/r7/nG7RZH38FmND9PFOu/z+afldE9Gn8CU/f8ZXhGcM7kgvhlnkQk0XWQtMEBml3/hvLd0gbQpxGJrqQVtsMBABypnylxJH4trsOzVEGVXaCIrPj+NPqM3emTWLVJGl7P5NuwJgsYsM5JhbSfjj5DupljaJmcon5eQP8ep8qtk9ul7UCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6159!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031329891779"
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
