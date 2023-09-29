
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064354624217"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064354624217"
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
  name                = "acctestpip-230929064354624217"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064354624217"
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
  name                            = "acctestVM-230929064354624217"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2711!"
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
  name                         = "acctest-akcc-230929064354624217"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3NOuJJcEAS1CpKCf/VxQIL68mN+NE8TZ872NyOZwe1g53CprdYKqbkfce8IRZO9HzCH5CsY685xuhTUsEtfjYoZkeQJefwb04OgVRRIIyimLRhBMIjjCpcZ57O/m41Ejc7fLYkbb+xGxf5RbomN+A13bO+VKd6tru/BGW5w9jFLkcJabOH4UHzn23OWrIYmYMjzSS7dSk9Rr1gUJKrP/NAz9P6E0oXzTSHufarqbylXJNbEWhEdhmLt0UY41n5diWCvSexwbV90UCLRNjGTZg3ubl9GcGqlDQc/IIYutXKHRuXqOE3Z41w+rhAQKTfyTSvEqnsxA4o+0UMx7Ej/cfw0Bi0/r0D+ZJRC+D+Q8lFFvWzORtD3G7rakb0j3o/yBWqdFx9AiuRrm054ThDyNqZTRrn8Ent6C858T0oQYI9MQnqUA4zLDWEAtrwkfjDqhNe4les3eNQyoUOocHbMaXb/VcN1TBosOwnU5GXINru0ciQUGqdW630M9vJn/DXq2eslJiuJ30eUsuTPan/7Acsf5sPN0/O1czufnEdNB/oK/KqaJVwa5E8YDog3YLb7kLvpjgoK7OkVchBhdKrEjdqhBGLDkihuUabEFyR8kw2YEwRXT3P5lFsoKCay5qmt0ferziT+0aKmtNZ3aEXBBQ6FZ02IAgwXnfFJObsSwgvkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2711!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064354624217"
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
  name           = "acctest-kce-230929064354624217"
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
  name       = "acctest-fc-230929064354624217"
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


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

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
