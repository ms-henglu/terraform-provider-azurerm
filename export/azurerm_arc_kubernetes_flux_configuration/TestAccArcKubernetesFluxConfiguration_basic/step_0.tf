
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074258127855"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074258127855"
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
  name                = "acctestpip-230616074258127855"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074258127855"
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
  name                            = "acctestVM-230616074258127855"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5430!"
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
  name                         = "acctest-akcc-230616074258127855"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAysLxSNWpUobClAvooSH2wV/UsKtgQ0GKXHJlZdr6V47wf2WfvshUXgQNLIlbIdiEjSrrZGfRjG6wMwYgt3MlplzJATCyYv6YXCzPHF89cvD5VrXU0Lj9r5NktmBE/uw4CSqqdpodJq4pA1BxK5UNP2qaG+g3xVT+ZsXKIi2PuNT16zXWznV3vyHChppeCaLjQRbtZgC9KmEGnqtmLCRAqZCvOOC5Y/aWzKt9JrcVaCgQjmyYK5qBlPg4AkXVCGz3Oja1AOsQ3cPs1KZPzrqgsVssbPCG0exak4C1ZYJvkmikybEcV7MSV6Gbcv2WMV/O6l3zl5tdxTsDkRLPqStFxtnuzhB7StIZerljpCgRMZ1BVbyWAq+F8B5PkX+pzBLm7DEoy+z4RPM7qV+/bGjf06uSfo74OWEwsyBbRrGGxMl5DDScaY/EEksC+ssE7Pu77pL1UIzwqJvMJsw/OjsCdn0PzzmxUAuLhaBFsb8b7acpCA512Uqbt3RvZEXGa8PsZdCAF15Icj3XLoTr4vC1oMsJ+khZy+XlY2CrxWKgLk/66Tl6F5sLmvFbdbqXv+8idOvUzN36SdrKAIsddHjdwHmvVZoN+lej9UfR0dnwtF9tIAUowFriBwDid1N6pVKcK8OIaCziAZc1m94giOE2EVj5fuq5Nh3OM5R3qeOu2SkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5430!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074258127855"
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
  name           = "acctest-kce-230616074258127855"
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
  name       = "acctest-fc-230616074258127855"
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
