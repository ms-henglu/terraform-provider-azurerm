
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071347208143"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071347208143"
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
  name                = "acctestpip-230613071347208143"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071347208143"
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
  name                            = "acctestVM-230613071347208143"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3!"
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
  name                         = "acctest-akcc-230613071347208143"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA7UkwBBBNHJ4JMmYzfvCAzGQbheWFYxzXXn28lHf8jhjH3v4QEkKVltOpnH0SBGery6WpYUnZlHEky+Oc8WHmSoBWpiROKiqAVWDO3DE2YwNAF8tDEnr938WdcISV9BwbvwdsAIS9AVx7VrDfVTQZqo6cTOSdfJjLSVLiEFzz83gd6S1+anvnXJObK7RD17yVXx4pdixRASqAFEPqkkWchXYkUYva9I0FncpIguaThHfdM9pXpdCJdmFEn0RKOV/XdPp+6Dzjtt5tEmEKAF/0T9idLJVCko2+AeUHJiEbBpO5tjoWYTD5dUy/oQXJjzgeg6ddM0tnMXZljICEiofIfCQn+a9CANRu5tv77AMDNgU7UP+noUbTg5B8uaYdF1LR4p767CBBLTAQx//rUw+Syu1/DxcLfUUgB/OpDsUZygcuAK1duSTCp8QL6hpmqNtJ6jgJf/Czpn6bKb4LI9z3zNNgJB0ugxprDAAW9urZAICNvUO+uAQ/MhYeQB2pGRmZO8DosZxYOYokeGrLQhixwOK40g+ISSVif5DpVbfHqoF3XWGEoRMu7yKfXonl+KIilt1Y69caLstaYWDfeWm83tdvjdFU+bXFuBEVy23PxeSTQyxu/i4B8OLkXYQN7m0fHdTAA0UEiv8kU8R5I2XpZBSdAUT7nYr51BJ5woWdnq0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071347208143"
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
  name           = "acctest-kce-230613071347208143"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa230613071347208143"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230613071347208143"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230613071347208143"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
