
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032658761130"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032658761130"
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
  name                = "acctestpip-230630032658761130"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032658761130"
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
  name                            = "acctestVM-230630032658761130"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1075!"
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
  name                         = "acctest-akcc-230630032658761130"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArlxIYxsjspyZ+/NrQ497MFeQV/Fm7Rdw5UZFCDGEdoixwstUSX/AHu6ls7RUN7g3OklqHNnsZ/mKFAS4URcNj+GAMylx1ZsdyCMFJnlQsmJDD9YiWVPwD19q3NiUtCLWQTMXJLZFiR+WI5MDek6XBWoGqjHkBvqzXNZHo00jlcLICkyl5d0WvW+XT6lFSW6yKOsJwWiFnUDxAnez5RMCd8AEcEbB0mwPz6zBL4WtaUGOT2imUevRQy+rnCIMaa2fhSf/E/HnqDVH9D8JQCw80QhsYst1LFPGIZ3QZC0CTagzK+nr0HAWoCsXtg/g2ATDU1Ng07YHrzzLH+KwBmxs8TJOIaDo4QWnIQJcn9V03slEN7yzXW8MJ3uJBfZf3MJF3HGHTap9Wq5oqRooh7tC3+v9ilzHaSkao3fNetL7P5hYe+VEj1vJZuAQZ+fktu4svEEKvQL7FK4jthUGbtjhzrRbhKGV1eZ9Tkt0zO4KEv0jyBMi9SgTcyTx43vpRvg6PJzrPngF/71GKmU5k1KNAgUbypC04DgjEXuI281V59jPN7BpLHCMKdNXNIC1TYPQJfVNVsp8PBeZd0K55ezlyc9uFC48eadQiFW4NGGC1Jo8BM08mdKChe28mUjJvFmJO5BqqDneunTvh1mvWoWmmxQFqLuFJOUZ3nQBdgi8TWMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1075!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032658761130"
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
  name           = "acctest-kce-230630032658761130"
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
  name       = "acctest-fc-230630032658761130"
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


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

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
