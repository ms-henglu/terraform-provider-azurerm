
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071250772217"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071250772217"
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
  name                = "acctestpip-231218071250772217"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071250772217"
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
  name                            = "acctestVM-231218071250772217"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8099!"
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-231218071250772217"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0nnUtYFENoL54AWg9kCv1XwAT/laO8pEsQg7E1Q/TbMAiQwBmfBho3Qi+r1wLiFdC9lrMcd6Kr7KXp8u/GZxKsp/VOPzR7QZtI+XGgakXvJcfQLazw2zCvdNWGOsPYiaYw14UN/p4zboGnlUEfLP1JdPUeUFNtTvnuNgvmX04inmQFZSRwyEP7/2A2s7zxmvgA6BIO93GHI08OZDjPhRTZ7hJgLZtmCUZj8GhDZ9c/RC+Gf5gcMuCqj4S0l+NqxM48RTJx/b+zQoe2SSi8zDXqO1yQFWzuGq/a1kdiXNdyfVXDy8B3E7PvGcL6gwqpfqy27Sr8sYzS9f0JfaukVZ0O45avN8tYVmnsFLE+IBGO2ouSxKLU/uzqYpyx0G5jePdJ29Za6o+CVD8puIAwpljGA93OWLU6oHYbQIVNXtDYwcE2LpX06XuGvKsIIBev36GJ+Lah3Toen2sRfj/Qk/3XnMpNRwyUXwE/FQ3tt4KI0LfITu1vtrjvYlXznT88fLEb1GkhFl22nIspI5lICO+DoLXNyXgKIrM/V4cYFhmCQ4n+IpNqlkSLP2C6cIXoGMErL5Q9D7qfn+6vdPO4KfBfVH9tLBv1XCHeJQKwVY98eIhJJE90SwG+HeagVJrunC9Iv2IYWTpX2ba+UD/jay6IRq4t8awZNTInPMT1CCwRsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8099!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071250772217"
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
  name           = "acctest-kce-231218071250772217"
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
  name       = "acctest-fc-231218071250772217"
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
