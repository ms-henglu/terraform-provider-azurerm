
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023533628767"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023533628767"
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
  name                = "acctestpip-230818023533628767"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023533628767"
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
  name                            = "acctestVM-230818023533628767"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8677!"
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
  name                         = "acctest-akcc-230818023533628767"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxZiNDqP68XNCXafONrlj9y6f/s5iBUWy1rBcdH18baXM9tUPDPjOtXo/DMN6gFkzHdxgY7CgBTxH1mX/YH0yX5XoToflVGcb4Avr3kiweCz29tGd9CG/K0vw6UDuEt5dNV5cr7E3QElUlT52IaG3OspsQkC1d/7zWW/JVyT/lsZ0m3aplZSm1IfF04qZ4RUUj0VZDWk13/qxlGsZ1yRL7knpknPqbvffasOsCy3lXLsyvVUnRFhFgeUQuoP4ZGR+/wFFBB7V+XDb9aKwMKKqDeGzM4sMkbn0m1aV5WcqD9L778lS+D1kwWWQvUoSP7DLqo7yPlJhOROC/AJv3xIm+Y1LDFkjIP0sqEubp3O/4+l47l2NAAqbVN362SWJXMiAkf08jiJ5Ya1vR088SFVqK1NP/PSyfQPeVJ1LE+k6q1KXFIj8Zoziws0XHyzcnRKiBAJsxaQPTZNajuMVnn3y+zOvu5O+Z4yTRGzOpbmvSEMP9p71fUdeP0mgZ3unrsxjbliORmeDOj4kW8dyB4layX9D3u6qQos3LZS20zEwSPov8XcGonM/ajCSNC6FJ4ncgBP7ceDUHJTceB81B9Sjv8mewh8WiVy4oy4JYsTVeLW3Svu3HZfDrGa48pS/QDkWPb+IsKD8RYcdr0IkYzSNUXwqzlJjjNcMC0ka+jPUHX0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8677!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023533628767"
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
  name           = "acctest-kce-230818023533628767"
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
  name       = "acctest-fc-230818023533628767"
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
