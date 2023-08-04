
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025437590126"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025437590126"
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
  name                = "acctestpip-230804025437590126"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025437590126"
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
  name                            = "acctestVM-230804025437590126"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4395!"
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
  name                         = "acctest-akcc-230804025437590126"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArg2mjtJxs9bsI/iiiKBDc0KPS7zmgrKHRnwUyCYMH62VfuGvmldL6U40jFUodlfukJG5OsJm0pjJkpmC2DR/YyE28RQLNIS5TExJNVaSeU/S/c2K9zbLDbHhJzeycwZbPwKgoRAaHDNpCSUac/0vPTMsgfavDucw3b9Og/ezKuWgW1/SSqDv1Z/q/eycCRzVN9CspLme5Ux29TKOZKk+v2cwZsCvaxqXAze0neUITpf23dn12sUy4wA13HwULDyMWwJILtNCcJ4HU61q6TmOp5W2NKgoaacZoZi4ePP982GCblnTI7Z71xl/H4Yt1ymCtkNWSFjW9l3kuKGKPxdzeN2xsIlBdqYJTEbfEyiXXLJD4NIURTjiKRAqRFlYEX8/26QyGBnDad9UUfFLuVbnoDYIrQIs85C6pr80aweat8T44ybJ+s1jMvdNXjiL2GcUWS+qZTfE9uZeN4YJ0HV8Zu1dZtTFvdRKgvAffpd+1Kc944HS2FBsljlXXWCR6FkbW7HeW7L69kn5CLnh52xkXlQjNXjSZ8q1qM8oWDrHrCApn4w96ZfmhcIDIKDf2dhY7250BOhm19FxnXnSuM8OmBuJzSgy1TNW9H6O6z/MAb9g03arjYzlSsJkdt+v+z2m5qK8+XzJeDWT3/OUb5g0RbJOOC7DTM1dyeYcgm53WJ8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4395!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025437590126"
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
  name           = "acctest-kce-230804025437590126"
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
  name       = "acctest-fc-230804025437590126"
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
