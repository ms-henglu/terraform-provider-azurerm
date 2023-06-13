
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071346374696"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071346374696"
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
  name                = "acctestpip-230613071346374696"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071346374696"
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
  name                            = "acctestVM-230613071346374696"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8816!"
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
  name                         = "acctest-akcc-230613071346374696"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAue9RURNHeqh5IPd5UL3N00hklL3F/nrjB2lSUBjaawmQNTWuncDhclwyuKB1mEb6/XIp5NFinSH7MeuhGt9tXjS/zeNpPFfPy1ZGB2zorsfjzq2zFa0IgR873yR849TuvI9edQuVVJLzun6BPI6ap/nGUUaSrxPOdT15OKRyRhGnPQoda9Kqj4LvL/dL4v69EW9L+hocPfdZOdZCUzi6MgKqWwiJHOk6MEeVd+B0laWdYxe83B/pWsgeIyO0g+tO/5vG7SVI7A+/YRTtZfac/q09vandH14bJpWtLeoI5eAQqV0Z8x6rIrZBmye6o1LIVP7XSjFpn67u/EvN+P+PStCziZfmMnceCBSJnEB6J03gILHij0j/eXzmh77QY1TDxlv7pX0E5IOnyyVrLKSYD80vGrE/iZnfWnXjold+Fd+ReMA3KyK4qF9spRvBC98+vyE74Z13feWSAXTMJKwi3sKMpy4iVpujDUVkC1BSl1qSjKIz1NIp7lk4nbUnD0C5gNfmwUYBu/yd7KLZEHHlvOqKZksUi0efOl6n3x4XEbcPngPN0Zaoq05y/KM669MF571MsbmGZzU54V8/jTG08wlRIdGGrCENIDPTklcgxpupWbfTnhJKjLalii8Irs0CZsGFQ7js33027cpLcXMBdcY10RaLd4FD2Y/8ayMSiHkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8816!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071346374696"
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
  name           = "acctest-kce-230613071346374696"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230613071346374696"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  bucket {
    access_key               = "example"
    secret_key_base64        = base64encode("example")
    bucket_name              = "flux"
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    url                      = "https://fluxminiotest.az.minio.io"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
