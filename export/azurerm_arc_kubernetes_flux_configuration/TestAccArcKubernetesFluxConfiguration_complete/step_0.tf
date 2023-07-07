
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005958395376"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707005958395376"
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
  name                = "acctestpip-230707005958395376"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707005958395376"
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
  name                            = "acctestVM-230707005958395376"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3537!"
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
  name                         = "acctest-akcc-230707005958395376"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwkDeUstdpAmClHl6dDpzcubNcFJ+QuzO2hvsrOLUNNG3Tj94gXImSgpghdL8ejtATpzrcstB8jfZocRY7XHxO5FETqrGDtV9Kyzg90UGo3Jw2anOfxILlYSqAdkbK5AKon5r0kZ+aosEHs6xu/J/3rgCSkm62Hw8WkJcovoE8k4jS7p8+In1ewyXA0uLC6dDmfZOZfmuZtBC4v4e9LyKMpq4dbmk6phTbwhbHh8Yrbp9cBqVnJclqNFBZjYY3n8K+cXmiRvtZq1wzDsVLK3XKO3mhoj7lVVszlDCKFxKmUGIsb+hkKTOgVEPVl44BZwIHWMzrHtpMkAoPKYphBhazrDL9o1jnVdwoyMLGHoFAUk5RaUSVg9/NT46wfvdayXHzp6mj/R+YwMDI+Fc2vw3zpOG9qivxn5ulSdu4Iicmw+E6OsxSTEA0o1Le2mVY2j6fsufEu+MeEAqdnPh5cj8vd2Dt1rb7p85Sn9Ld0X5kaz7kTh/9kkvE+sr7dYM7/IK+CIKnNkki4x0YumJlG+VDA+lOBEPrGWFTz3heJVu3ZjtHNzgYOqFs2Z5WHJ8ETsr1Cw3UiVmXnFTuvl9p3bCJcsJXdnFkN61re1k9dF42OBAXnv7itGFcFioYzRu/ekQ1Yo0D5jSAnnwoKaJuDDgSY3IyqdeOkOtYazZCCdS2r8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3537!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707005958395376"
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
  name           = "acctest-kce-230707005958395376"
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
  name       = "acctest-fc-230707005958395376"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
