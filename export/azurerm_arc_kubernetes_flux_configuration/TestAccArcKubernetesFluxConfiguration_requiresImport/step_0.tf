
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071342378656"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071342378656"
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
  name                = "acctestpip-230613071342378656"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071342378656"
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
  name                            = "acctestVM-230613071342378656"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2469!"
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
  name                         = "acctest-akcc-230613071342378656"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA6yIKGW1vDfOv/784zqRWCiZ+KLwiZxq6/3+990JtnHSeypKUHBe0wlQUhB4FXysxdIH+/7jrtxmREOClcqPgFDA7nmbVPQpu+B4j61VuRNoHwn+MtjC2qWq/Bf0k09bkvsK9lPuVPwKh+SSAGJfwBW/9WNNd8NqyNoYFeenVr8dqRt3Zd+bvZ6USfI6JabIDfHE/oJjgARLuw6B7vSV40sNCy1e7zo2A9yDtuvLd5thgwzOfov773eT7nH5CRP08hGeaRBrjrKfYOMgGIu4mkkZtN0qllvBivy/N1t5T5iCebDhHbeYBibXtphMH4A6SIZqoKs7YIoGi4IjDFL0CP7MF6AiJ3aScyn3FQn7b1gkfXcYt/e15VQvJZy1eUxNZXqproaY41DgRZHaCHEIJYGs3qSQdjZq1yiZSaqYhTPj0z99Ibxyc/o9M7JzfwANLQORZmR8Q9oj91xYSew2r5aTijBvaQY8Xs1bSRyVcLK1YlLbmOblxNPxTzFExXhW6vV0bdlIGEtiXJimKqSPgQ9z0U5yuOqyeMQjxOLFKMGlwKqS4tXm+55HnpgXF3/J/OidCpYThdc4UuQBVI+1yfYE7pX6ikTItJM5e0h7yrKEEjQPiGd3vhDXfuKYIM6XZqv6d6L5Nw7+4mz5tEcPONjNoeG8YoHR4rMS8+6DYrR0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2469!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071342378656"
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
  name           = "acctest-kce-230613071342378656"
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
  name       = "acctest-fc-230613071342378656"
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
