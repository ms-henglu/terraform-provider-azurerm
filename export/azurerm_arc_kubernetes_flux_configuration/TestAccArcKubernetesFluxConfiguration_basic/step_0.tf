
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042921253727"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042921253727"
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
  name                = "acctestpip-231013042921253727"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042921253727"
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
  name                            = "acctestVM-231013042921253727"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2677!"
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
  name                         = "acctest-akcc-231013042921253727"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA8/aJ1KNz+Bg95+oFizmaAjMBmm/E5wAxxwp1UBMKpgT+Kldf5q7BbYdCJn1KhZV2QDKfUKoiXj87yxM/SYIfxNGkmvI8hkZX5vmWllSNq4TIq1xmsKCApHDtzNMorYJW2VvlmV8g/w3ro0JjNHn0m9r33DkiT6+k+S5qXlFlX4z7mNlGZJ7wb5uhwsoeliRDbzojDaG4JfY+skin/YciWfDFXglZHNoNDVh+T53IwYYXBwHeNmKOyv63o4GjMlM+V+omp/NK8H7MkpBqKCyg19hB1Al1qGAqGOlqpB1voOpbrtGU5KAZ9zYe/agwv7NhKANSN/AQqREZJeegXm2X8Co6i2Q1/FctrYvhMPRe1wnI/zMbVAX5Gg/UsS/txUt+nEI2961O5O3R6koqlJJ/B+H20Vudz4+aXULp8X0GgQ4tTW1lrtrcfq73Xv6qw/s8gEgtTyQ57hPFXNm5sWsfmuLUywL8hdL5B6ncuNePtC7KVza1H77MN3A6xeKUMGwIpDwseLNudOIXzX3jutMkkRlJx+u3BkcCbCdXnwsE5g0z5oP9kH6056R+B0C1FztlU9BIsBM2CxpQA2L59tm2TUAydncwNTK6TzKA/FbUxoZgkaPlWva+FWTdS8Oa5wICn0DB4guZQJKiUcaNFLw96wsZQnCgyuWRzkgULHmN+1kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2677!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042921253727"
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
  name           = "acctest-kce-231013042921253727"
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
  name       = "acctest-fc-231013042921253727"
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
