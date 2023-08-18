
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023541711109"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023541711109"
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
  name                = "acctestpip-230818023541711109"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023541711109"
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
  name                            = "acctestVM-230818023541711109"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8111!"
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
  name                         = "acctest-akcc-230818023541711109"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA8y3VzAJP/pbRG8ZRMfYv1yqQILHMCeqAhtW1a/UlVrVWvBglwKYEm0Y5qadjPPq0Taxwswu6SD5SXu6yl1cjvZ+KWW1yj7P6JqzTi+WtZAireF+pOnoJE/4CkqXu9wSQDFlDMZk65WzCF/RdsmiTGGxWtZ0y+56ZWNolrlKkEM1nji6VzohP3PoGxAdpisKXtepVGmzIkJzWmrem1ywJ8AHRIH6nR9bxFyiaXAJI+cfTFltCUt4I9d0E/mn0Qk4dpW6V49e48ByOwAwMGu0rx08EhSDFOSa9yg26Work7CTYcGPpqoy5Fa72cGfYeyW/ONisy4aYFCpW/Q6JZNwysdL+H1KBW5sqDnKW+08VLDASU9/XfKIv4whlC1UGHJOiwBW4I+py3WLWG5+lkmenh6wsiC2k0TQegm6w9mGNnUA/hoPbI7LX/suR+0C/NNV1lMfWtq4DOVGUBh2VAXk0KNMHxwM0bYcsbo9ELAw4o2zdHuzTmqjcdD/wyPgkfQWaPdX1iHY/JA1bahBnv/qyBRCxOVSuyEnvdZMvHijkbz1B/kTYJ7TjKKRxoqDU5cj2QQBVKacprwKKUuRhwRQbOTs7738WWn95no1fEkoYrFO2MJWwqaaW1/gTk8SJ8tV+HwVu3Hcz10zM5jErboz/veI+tV0P4YI/zb96btwqoUsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8111!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023541711109"
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
  name           = "acctest-kce-230818023541711109"
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
  name       = "acctest-fc-230818023541711109"
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
