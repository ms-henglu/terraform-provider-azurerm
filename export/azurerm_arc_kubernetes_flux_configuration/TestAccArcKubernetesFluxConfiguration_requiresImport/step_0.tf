
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014508696510"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014508696510"
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
  name                = "acctestpip-230721014508696510"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014508696510"
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
  name                            = "acctestVM-230721014508696510"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6426!"
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
  name                         = "acctest-akcc-230721014508696510"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzdm7NIwQvkIyt5sIo5zpzbKLSWiMPpXQnxC6aC32O2Q9dwpiNAUZtgU7tL8R2NjNYPmQzFdrCiA6Hi3M+XdHADsYjuc6jg6OjBfB/MicNhPgZwCUImPNcHCWUg6+jyyycnFLbGyQu6MEstbp2I3iBiT1sgy9iVIEGn6+qvU2U59/jjRhqCEh8FvhNzkEa432JfLqyzzWY0HaHMH44AIjQt11t7J+tcxBilr0+PNjx9dX5d0OSvwoQZ1Uuwyvc9TRgym7GNBXAtEyiIUJxmbN7wgbU3YSdmtMQ2tqmljGXTKx18U6eJT72vyDP0f6rNkn6OVr/S78iXR+3+e7SltdLLWTAGJBInvjZw2EcJZ0jNocS/0qVP0Ix1yaS77WJp3dRpqSZeIMn9k7tyGU4X2HWhP0Fo1rGg+y4etOx/DhokDykPjQGLuOucaMZr8o1U81qstKU2UWJishqnHUSW56w+sMrZ4A4SyTXGPp9LjrCnmanq11X0U7ST4bTxQ3BbGWbBgoeQT4oX/3kMvYSHn75rc8+TkAjdkufrOp+gJuQcpwY8taBluoe+kCYDCr04IsCSTiOBU+488KVAocUQMLldggv4xpCzz7Hhr8LYM3RRm5w4HBuEUo0Gpt5qXB0MLN6MEy5hNRdu42JQ4ciDI01WLCt/J0q+n+c1pP276/jQ8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6426!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014508696510"
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
  name           = "acctest-kce-230721014508696510"
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
  name       = "acctest-fc-230721014508696510"
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
