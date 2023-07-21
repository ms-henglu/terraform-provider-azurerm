
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014506214675"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014506214675"
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
  name                = "acctestpip-230721014506214675"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014506214675"
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
  name                            = "acctestVM-230721014506214675"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4315!"
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
  name                         = "acctest-akcc-230721014506214675"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArAepYRPm40sTwGc3UrWyFmrb8JkVJHnGUXK0bYsBOQbeBwBcfXGlkQ/n+vZ1+yUujVt3DzRPLBokDrRNT0vX8ZlTs66w3VYM8LM1UoBNhk7klOZyvjJdFi+eoLQOYO64NweHTvkeu6YN2dyKjttZBoUiRHtZZiRytflkZR+jLA7fvRQOTQJYHDI7j9/fq1/SJtdDuHznkF4p/ipbmNsQxRFH22JqIyzjceFIzJ29nn4z24janQNw3/dfOeQXEd5lB5c/Kgyi0hq3wZwLpEtHUpd5vSxDZZN3c6Dnfi+1yQ85i/3Z6Q2YQTvVteWWxvQWPbJvtIYTE5wztZp+uQtMVF5sDJMFMjJFn3oeKvL0WK5E/IUnHTQB307/icvhQvsk+8cyHWWSlt/AbdkTAzhvYAwoij9mhV46ThlaGXJz2H3by4l7Vus53qjJro9zxYn1+MZJ8gLPVSSCVvUna/9mNbHuJomqBOd9KW99n0NnLEQWLKAE+rU1AgEdtplgahsOTURfIPt3Ww/gioOAjLRUX+mHNUem1X6nQetAxdpqgy9AnbFY8Pipre5OEO0YvRsUOPC2EXAqPxOGaFcYL9c6gRhiO5b2zw52o2oQV9u6rgcPj4xUtsexCODVYykTtlaIntPlmOJzz0LV+uJUwa4qbQ0y/fSKwHlWxDtkbZitW+8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4315!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014506214675"
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
  name           = "acctest-kce-230721014506214675"
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
  name       = "acctest-fc-230721014506214675"
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
