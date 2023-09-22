

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060545530424"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060545530424"
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
  name                = "acctestpip-230922060545530424"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060545530424"
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
  name                            = "acctestVM-230922060545530424"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4299!"
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
  name                         = "acctest-akcc-230922060545530424"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAy/bJ+PnuYEYTygf4MG6J3cJRzpBQcw/vDuH6W+6btKFrd18OHX186IbdCG2624MvDLulLqIIZBwPTAUnUbKvm/ktvRiC+Ut8jUoiEoY9G4w3tSCkZGQ3XHUc8AUJTv4oJzw5Nuug8VSSmfU4O10ZDYboxKXzaQuyhVwyFzftuNCValVJGFePjzC3TLdbpPAl2fkWKi7WEebxudyZ4Da9V4VT0337O8FmSYe+35yjStksBA7QkN63d3+h5snCGM8/C0jq1aEvosnreq/VolDi+j97DrrNGLV7BfuouiZN4oijUbamOSIT7Hzj+WyP9ZeTXDLrVOjT0qWpXuLyPh+gM0wrWOaCQxyIFjadmGT0gGwGiFFMFGbMWOv4uIDpJhEG7ofHS+yNgAp225BmhHmICNIGt4DSyVsWdwI1xRHspLtNhYoipAUQEHcZ5neiP2P5vq1JrKrcu66KokGIYQicED44IZJW/sO4iiTUm807lASWkPCXsbRBM2ERNEo1szQ8tKQkTO8eJd+fHgWzE09DRqXS7eQxNVEMw/f9yMdcwLH8lkRxMVrsgANhX9xWGJRoGoo6ni5XuoJ4SMrUyCEg1KZN3cFIMbfuMUnc1VRkvYWLQ0trUFxO5/JOOYd/w8/cEn/+UbQTgMr5Kqbm7e30PDFShoMEA7axa8AxlswAeCsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4299!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060545530424"
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
  name           = "acctest-kce-230922060545530424"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
