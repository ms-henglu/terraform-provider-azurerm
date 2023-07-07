

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005942757973"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707005942757973"
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
  name                = "acctestpip-230707005942757973"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707005942757973"
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
  name                            = "acctestVM-230707005942757973"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5762!"
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
  name                         = "acctest-akcc-230707005942757973"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAt7AqiPVp1PX9+gdllcNG2mGPUCMvlOCYHKz+UQsJotQJQnVlJvlIdAgvg6LDy2WhbkWYoSig67KgzxUHKsCPpo+DKgFFrzPS0jA48IH5qyyTnkMb3coVPLZ9Y6qeNKhLxrwM/fo6952/Vxz35OA0TR/5e5YESiJ9P2j0l5Wmh8miJrNtV+GoeA4LCB1ADKWFeYEsgmj5kCOjbt5bs5VYFTjJXFnFmSyF+wxpPjq+Xb1QD+/X8pB+VcMZJ3ovXgoFa44Le2vLj8RAay5zZ2a2Vda4NSeUZJ+vCuF/HlJ2oN0zLb7GdqL7KIdcSelj2UF5wj+FPDazkckWq4lxQIO2p8NaNI4TKKufMXvzxwDxl1SInmRcskisA8BVe+fURA0kdYaRHmCoj98HQbvGvxdnoEAfjV5fVmbJQWxP3JLbpJF4QMsuWiTT9+qwd6zoBY311ZOgwRB1BP+yGYfcXw1oGVro66s9So2bnCNEZjlpNUTotIcjXKYiW1sG1vrwoTKN7q9cAm0YOR4Jh+v1Z1JAeby1b+9UOgnxYP1E/QVUzG8cJR1WRRznkiBOAnI7vIlfqp1g0o2m26dIYaYbaP0+NLhfRVEFzDCZo7X4UDXjWXtS3d+Pu+c4hKSsN7sgSGGysMeR7BtPQo/fd5xRh2pwczAvLc7lJhkkklZh5VIAT60CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5762!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707005942757973"
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
  name           = "acctest-kce-230707005942757973"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
