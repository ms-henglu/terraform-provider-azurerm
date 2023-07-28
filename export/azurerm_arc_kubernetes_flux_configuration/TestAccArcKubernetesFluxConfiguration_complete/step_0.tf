
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031800987822"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031800987822"
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
  name                = "acctestpip-230728031800987822"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031800987822"
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
  name                            = "acctestVM-230728031800987822"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1313!"
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
  name                         = "acctest-akcc-230728031800987822"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxooqIl58jJVhmUeQsCZDBL6sRBNVAJtGLlLfWgI5V5RLqHGOLJ1GODu60RdTLe16cQgc1PVJnsSnbBMREz/vNQ4CZZCkd0UyIV5oxt/+DIXWXU7ROSY85YACoVRrVCukTBiANDBB4cW+f0VqWoG5MopeWiBNAnn17A+ThGnEN2ge/WINiPk50mewa5f7RbnCGf8ow3bZ4006GqBE6QsSUigRpPl7+lbB0Mf7+OO8UAgVsQ5RnwF5F24+MIsvX7BUf3WXnstT8ynqOPRF0X6gdGu5IU7rebazCrZ6m+a4aeY9Dh62HsOj4/mWrnp3pgAHJh+uTKOfgmdk7ip6uNTgDBrsgzdCCC42iAW88IX0FjoCXtOJ1U4VuBN3/enPpFnIo8Pk7uYOTzfwJxHDfSlASZqQulDAC8Fxztwlg/bvJqCZ3aqw+bqB8HsMKQMkTdI6l6EYk5Eu67YsfvdUQGgtjyihraXkkjjdv0HWAP8/SK4UquikgVV00QCQZXdlArtB8W7wY7LKv6wK+vFATNMlD2awIAT8qQpN9hEOkpfKiIXtNe1RyOMByZxeM8T+hpW4GLuWUo8zDiLfIgMEe5LoEGpyU28Kxj9BOw6qUeB3KMJ/Y2MfuWRd8vdfJCJokyT31CIkfUCXQIxFS345bUkDnDox8V4YJ9OenpE4XD2e7G8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1313!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031800987822"
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
  name           = "acctest-kce-230728031800987822"
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
  name       = "acctest-fc-230728031800987822"
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
