
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033852724707"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033852724707"
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
  name                = "acctestpip-240112033852724707"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033852724707"
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
  name                            = "acctestVM-240112033852724707"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9575!"
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
  name                         = "acctest-akcc-240112033852724707"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzmUTVySOwgP4JQ/ZtIN7jwR+4GJlpZsHTfG7TbcdBMkhQ7nEX5R5IUyznkYZS53xaXrKpo7bkhPu7jTgZuKzvIOkEuR6MCdXeP6MvcZZXYT52JNmIsNWIoCkrmlVKW4kGtPPSqsZ4yY0YPKXfLe71vckslKVqi8U1ZZrJyb6Dzz4H7SXyOVCxDdXpnGkwDmIdcT9Ha1iZ+tJVuSqqSLRd7k6DZbK7tXLm+2pHTNVkmE2QeNxzeovcbMiBwrkE5jBY09OYvpfIX/P+cYbb+W61tuqClTJySgAm8kkY7ohA6YcXeBaAJMkl+HlzDRmxvwKZ7h0sBPvTXEHHZno5Zvd60UsumQyZB5QW/6/zriLkUF6VTTWQlHR9loPVx0A4IvGxkT3AJH3OEYLli1QXIiT0298my+dhRznFhRoF1Y7gZF3KoeJzUgHAVCimqP+vwBWj8iwaHnLTj3sqrEgt/CBfjsBazlLpzhvkS6RMMnwgMo53M/6y7qygThs3rJ2aHuO+EhZOzyqdaUXJ64xOOuBKCUPHu+uFv3swBMp9zCs/0IAX+k7zZ6Q5b9Uiut8rDcjZmy0eKOG2QjzgLe61fVp435AFPjkxKbR0ohzC3K8iRsZI4D6xOaOMRsjPSfeLJOecEgXerzSuEWq9pjGMEad/oczRUhpk3cCJpnwE5xsoOUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9575!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033852724707"
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
  name           = "acctest-kce-240112033852724707"
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
  name       = "acctest-fc-240112033852724707"
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
