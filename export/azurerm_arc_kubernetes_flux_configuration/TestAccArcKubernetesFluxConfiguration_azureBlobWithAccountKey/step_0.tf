
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122332634175"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122332634175"
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
  name                = "acctestpip-240315122332634175"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122332634175"
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
  name                            = "acctestVM-240315122332634175"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd84!"
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
  name                         = "acctest-akcc-240315122332634175"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0O0gVOGxnErf2FvaAVecdGITLqBqJ0Z22oO/qc4Bz79XDvqsn3dVBD+53aXPxkxwTTme6IymbEOClod/X2dQkJH0IzBeqTyblwQHAJVQRIvZbQ48g3e0m0jgy4xK+2uUWtkj9ol0vdQRra1e3uwm3cFWD1KRQnKIlBvEX6VbgacZwi/wKVDXpFqLQE/X4KxTAIH9prUY6zqw7a1e8RHhtecbPbNrbrHWOHuZ5EZnGCSVfVznqQIvUlW7DA1o9P9iZwPnNqtqbHgSaJK/5X8a/EUj5V7lr6CiWh0iPyExY+B9ISnGsX+8LjwwLOvfXxnq4QAVNJ/WL4n2qDOAGJhp/7OEkFL0zqj61qAMIIWMLFe516A20zIReMfYuRi4JkbiU9Hnn9vGKkyK6P13Vh0mQv75Po+GtGZYyEYfLMsVriSRivRv6hharWPmvfAEwUeVnLU/78AYJaIWrvY02zUX+2fQ074uIvIMW3bBrSdpV24I/t39kPQVou4oOOghymPIRZI3SJx5dQlExlo2svilEnMmiKyXii2mY+LAjtIi1c+JW3LjWFA+y0mjUMjEBdbpsNXMqcObzlWciRJ07nSZoVupQvEsDmM1iZpv4DIU6jGzylBEnsUGqqyK7SWSCxixPJNdPCsiR7YIRwgEznq/Yd8xZeJRmi4FQqo801H4E40CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd84!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122332634175"
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
  name           = "acctest-kce-240315122332634175"
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
  name                     = "sa240315122332634175"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240315122332634175"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240315122332634175"
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
