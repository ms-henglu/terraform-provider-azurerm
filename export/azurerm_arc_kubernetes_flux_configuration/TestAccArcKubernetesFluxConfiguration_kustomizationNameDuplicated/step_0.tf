
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071355016386"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071355016386"
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
  name                = "acctestpip-230613071355016386"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071355016386"
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
  name                            = "acctestVM-230613071355016386"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6999!"
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
  name                         = "acctest-akcc-230613071355016386"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzYiVRCJVx25RssRTrMH20x0GWql47UM33MLNwCoVx+z5k3Gh+vd3OMXSRQtOoO/jizPJ0NCmcFU/iYEe7ZHzq77DQgVc6Hp8ZW1YYi0qjAphyV289DQM9O/L4yILmpw88GIeod1ioC0bb88gEk4KsjnIL9A2cCv03Y4Z/+AZpUT28I9AEP/YW1A7rNaw9CmxLZMvldYVHzeoXTw2SlPp+YtEViFArkMyJst4TctQpzXWxZyQ52YJuExoyX+44UoNAyBjRMCJTY8UvW7mhX9qDXHX7W1DYxZuPBcmvK6x1Xo96Hnl2uhz5YDH6AFs2ceG2XP/ywLiKGDTmjVkJpPWAHgCtXT6+tHi2eWOkb4OoJ0iMm7HjU3qPnBgf0QQVZYd0xvMrZJZ5KoejJTykmp+cxHVyZzQHXSjB+5cC3TJBOxn97BLBb3tSESousgFs5pZbGt05iDQwwXFXwegmbskrQVO89Cmz0pyq1l6dd8ENgw6gqrFcz4HhEaUvjQdSF5p6pkqgbB8kQ9y+Rh1pdOoJdqC0s+xx6aFfoo93tIVC3Tm5PbPsHLPmCL4OJaYzJBIv6Z8b/LBJMjTD1JWg5cnw3SmqWdsZ0jUrmFuELnMtWmjsFrJ+zuq2tWCubph5aYjQp10ONXfX6vaTUYTlvGuBrYZmyu9zEVDYwysb7gIbHsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6999!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071355016386"
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
  name           = "acctest-kce-230613071355016386"
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
  name       = "acctest-fc-230613071355016386"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  kustomizations {
    name = "kustomization-1"
    path = "./test/path"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
