
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031336587808"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031336587808"
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
  name                = "acctestpip-240311031336587808"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031336587808"
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
  name                            = "acctestVM-240311031336587808"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3258!"
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
  name                         = "acctest-akcc-240311031336587808"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwb63fUwRDK9jc5RKbYjLwuV1l8n5f/cyMTAMYyBKEaqZlUTZhWtP9IrwZpl0cSZzwxFEr/E+oucAllhkbWHY4qdLbqpOi3ddC8WVcYz9Eee3ai87FyH2mfNukP87JTV4xEPYNuc7lgV1AWA2vobCTy9p5Rb333D8k7oT+GLdHDUfjYIn2PA8DLOsYAXDwqTBQLNHhyRJ7kDk8DhS+g13ZCgv8DkFVDjLLDEYpnTld0CXDZQfD88Z/1+913iAnz6q2iAjfdlK5HCZ1EBdw+4SW9ZOx3QhZUafCPGteTEcM8lEvpKhu+8sDgdkXeay8+vjfiPOOYXjSKIm9hbmBZ1qJDTEpthmoNnZe0UdfwOR8syoNBWoREcDf8NpkfrQKVFmqgtXopCgL/hvpdyNMtew/tmQqOH65YLye53cK+mc7Fv+PBOON+Yv7TuXgLWWflNWa0trfbB/iTjd39QK+Q2onlZZpxwPO/kfAg/VugJCJ1go4mfg/CpZUrzazi3gYkLGogVrRbch4lGVFCp5s2DUdGuPxikq8Uhi3I3MaYTV8DD1tLM8D2sxT9x6DFTtSiGOVO+CdibvTiofQk/blet13CVu6ODFkigM/KwOJrLP0zGJ4te0Plch5aE90YlISZKC1AnzHIE3N/SuJ+6fOuvDEoPPu8EEcElLHSGAkAIubIcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3258!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031336587808"
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
  name           = "acctest-kce-240311031336587808"
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
  name       = "acctest-fc-240311031336587808"
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

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
