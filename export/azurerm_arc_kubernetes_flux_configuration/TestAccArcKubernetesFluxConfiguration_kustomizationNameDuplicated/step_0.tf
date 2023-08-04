
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025452045765"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025452045765"
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
  name                = "acctestpip-230804025452045765"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025452045765"
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
  name                            = "acctestVM-230804025452045765"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3079!"
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
  name                         = "acctest-akcc-230804025452045765"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0nsaOXgohZb0N1BT3dqIncK7DUrhZd8RrYUg6yxHagVEkjHRx+vEIaJAkmGA594Xp//jZtWDILGDLSoUROLmwLExeILB6WPaMWRfqGoP3M7UhUsP/J+NLcdpQnNvdqPQ2HCH7b5c0w/A7/CgrMtj6W6ErY0zbt1Aw4EiNsSpJQ8qQikPA+kL/ctScSd6MTQb71k6Gf76gMFvgIA8B5tUUkFit5uNmoGlKYDlVnwJP30vCuOi0FVEstVMt7ze5RhCTUeYMVcoHGMMDZpYAn14dgFE8pzTX0dQPdGow47/nqSeROuUT611R0pYwhax57pe3ZnjJm0+imKE72iDE9AebnFQr9bz9u8SzaeXjL8PFV/5ahMvQpQtjI1zh9k8Kwn9ZSWxAJ8n/UxZTcDY5ckGujIQssAyiZ/q5AI+OCscc/eSJjENdgAAIkAsS/2Fi+8nzfQvgDAQwWzxoqMq/ergX0U/eCvIVW0lS8bnRHaEdWI3EecaQ78rrbVw3eC1GzwDM5R6JZgrCWJ2O/tI6sdJjN4QV6uui9UPHMGTycmmbv9wgwcLNnKIEAgsXh//y12t3SFstG10tobYOptgkEkrHyvxL4BLSCVF3QvOYBFRqbmM7PT1C8bBF580hP2oQGuHzvZHBAKojkdvMPlnv6zh7n9yYgPY6m8DakXRCMEelSkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3079!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025452045765"
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
  name           = "acctest-kce-230804025452045765"
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
  name       = "acctest-fc-230804025452045765"
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
