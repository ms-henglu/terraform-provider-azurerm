
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223952397577"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223952397577"
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
  name                = "acctestpip-240112223952397577"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223952397577"
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
  name                            = "acctestVM-240112223952397577"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2527!"
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
  name                         = "acctest-akcc-240112223952397577"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApO+Vw6XlA8YoG+tCBpCSFye1PDT8irKKTfQrfGAHVxZoFr7kOFo+tBbVaymkM8vFPDIjQz0BntF3Akwd9xyBwr1cgcUu3zmRgWf4hkT3EL5qR69NdIcyH63HNXbNl8gkGZfd/xWIOe+49FgdAhecaAJjtcAozJ3WSUnH5unKX0H1BGCiLN7yYF3l9T3rKMyoxuxJExfN7qxYJAPbjfEmMLsiKsRLQEi+bgDNzyoIXRzaq2lJPncAnzOTB45qijFsplwCEvYoyvT7RQRQcT+fGHSJElAYKG4DZaX8dgP5WVjjGvCZHnawG71DxjmW+npfmq6n7XsCBceJuxS3ogT//sF8MzPOFtwsIlf7WH7MIWWhuuahC8CGyyvC+6+rBPxWFeZoHR5MII+y3cKxWLk1UwYLcDKO+jSWTAEUn0MMj/cSLZJhR/u03SQ9W1R4mSHiVBhFXsbS0dl9IWIW9AKDVSHznOXNhmPktqUZTUh32b1LqTW5MZE43EqW175bt9WWzAM0+tRP9uSGcWc7kQZ6s9Aa117PdK2+mFCUf0z9hXouAwvWbfAmgwPU2UORFAV1O4e9Pa4pr4rUM/TWsFJ+4lGRD6kyrADzvB5f6smaCyOondAAxifiCAJdRKtFsBasrge0gqtmE/jzvvON2e+LPJNcZ3FT5y9hyUAFz913nhMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2527!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223952397577"
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
  name           = "acctest-kce-240112223952397577"
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
  name       = "acctest-fc-240112223952397577"
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
