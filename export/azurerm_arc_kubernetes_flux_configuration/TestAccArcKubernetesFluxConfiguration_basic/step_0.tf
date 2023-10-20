
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040540833257"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040540833257"
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
  name                = "acctestpip-231020040540833257"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040540833257"
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
  name                            = "acctestVM-231020040540833257"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7474!"
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
  name                         = "acctest-akcc-231020040540833257"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApWslsyxA2ZwSk4GVkNg7vax6iQgnxP2TnO2Oihw7JEOGr7uVc4b+Obd3OvwHpAo4DFYi2ngdgF5/XBCd5Ihysf6nbSNRip152FWAYm1N34wFRPHzZtHGK/7pAp/QsofHQKdPbSvfwkshEMoOj3bVsPRhR/JttLCv97LENdsAJXqIeKhEzcKkdHmmCtWbMQUvTTxjbKitB1VB6eEgKinBmm0LWMGZSh4ND2udV7IkMMjXs4gpgBlhl5FrRFOpzjzWBH2j3/PgYfHQHbkSX1JwhfJDaCj4YDr1D0+hYWz+x1Mq7Y0m0LYFY259BVskZnZkcHgeU8XR4zGbscJKB7QS3q/bQaNvz2cSQGcYAKRLuCUKFwfqJEafC/dsIn2rqYbNWqBiwN//r+KrWh+G4rPht8a1rDosLglG+nHxTcpw5I8ZHqXu1WQUs0TyHO743/AOM/+eeDvQYGGz9Kz8gguxSVi6VLIi1waX/Qzwvs0Fo6uPO65fIVeJxL0xT5e+AAlV+oosHr5vMEEzKoOR9+RoZI0SnVjX2umYrCtnpYT0g3hprdhjzUKDlSS/Oe3vP5qPSKVqy7H2aJqUv9R1hq3t81ueitucC+viqCjYIlf0QY7/g24WXk5xxk+QYqAGUC7Kkkuen8fDtxWEb0U/+4iQuOcE/49e0pgomxnw92ic8T0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7474!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040540833257"
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
  name           = "acctest-kce-231020040540833257"
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
  name       = "acctest-fc-231020040540833257"
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
