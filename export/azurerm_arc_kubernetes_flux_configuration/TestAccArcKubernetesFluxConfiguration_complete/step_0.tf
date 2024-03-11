
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031338687474"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031338687474"
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
  name                = "acctestpip-240311031338687474"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031338687474"
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
  name                            = "acctestVM-240311031338687474"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3849!"
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
  name                         = "acctest-akcc-240311031338687474"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAszmCe+AAw3pJkSKHLbehJKLNh9zq0mB/eOJK/2yiI94flpV8qvc/obbnIzhs6R9W8rw5KlyVRpuwQFKEkoxk4YNzPTzWAzbhOgS7fbAnAwMSAlO7/mtH9pViRoYyCwRn03ggX0LN3vyiwb5N229h20D1beZYpC8HQmT9TEOybnz/5gXG7EMSJIlCRhOr03oRUTyS1PoeT9YNys+tYSQAaGEFZRkUMrIbkIB2x0WYyjX3gD205lvgPukPurDC5L8zLOlSabZ+Z52B6RloTz9Gi5byEcxUt7T5CziRrM0qRI5r42P8G3HxJmeqKYKJMRqHlnS4xuUpwKnAM8FeA+6Hc6d5hdNX+dr8UW6re/Zf+oWFFaDiPDv8znwM1ZFEjxycLNT0tTBUOQNSVVuruFhKqi72wuJt7rKeyehq46/sfZtFSSpeeEIDy+v05S9o01nADan6qn05P4Bd/lWKpxOmX4+jW5MynwgFg8ztCXIV7WVD6LMU9QdCPp+8gLl4zKZUcLNRKdTdBL9vEc5livIo6kHTtcCrvM1LcKIIzgZrPnOeNzHq3k9wcq8JXSA+EbVY4jh8iNUfshJRhFiK/o6YftRlrhf4HbPZWSZfQPR+lXL+Thz5Kd3fiNjwog40xrWT9glpbM/6OsJ0lQNuYo0UqimUiIzu4Uh7bGyW5aFE7j8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3849!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031338687474"
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
  name           = "acctest-kce-240311031338687474"
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
  name       = "acctest-fc-240311031338687474"
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
