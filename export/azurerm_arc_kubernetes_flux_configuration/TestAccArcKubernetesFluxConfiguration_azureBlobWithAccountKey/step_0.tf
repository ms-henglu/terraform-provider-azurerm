
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142950347236"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142950347236"
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
  name                = "acctestpip-230810142950347236"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142950347236"
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
  name                            = "acctestVM-230810142950347236"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1250!"
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
  name                         = "acctest-akcc-230810142950347236"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsFYlueY2LZABRMapNqRQ8G3mt8boedgbsreSGorkwsh6veLdkIJpfoVnJ56B9XyzEXUqcMFiWnFGgjw1EjWle+bIeJZHxKBGQb/ExZNvApQpSh93K1+bEG4zTUpsvadkTbJ42WDf72Ga0mpeLHQQFdaprp0HxV6LiHTJBT3QEvK6OogESaGIOxKkMma+HiuOXHShZbi6Ay4rgx2n08I8qG0uEraTYDMjT2w9cpDlgC52kljtBIeExv7aMYZwOST6YO1XMscoF+CKdHSwhpeIXLeP6h5HpbFrwyLAxmG2VKJtE5pHFAJA8NcnSsOQfJyFCfLyGuSBbaRX6xsMQi4ehDnscP6y3rfRlDHzshdqpCA7FMPQGPdAn7m45m+RhDzrZEsutyw1KvQGLo3jKQhaTCrKNpDU9m6RKYyBrvTuynAJdM8GopGK5ZgDov7bzJ6waZDo7rKw5T/pVWIAACsjbCVA9tebDwXH83gLgvgvIYmSUNY4O/0peen6fq75CMLSCP+D7uaMniKoL5DYgCuE5nbxgXm60RRPWnNQfblB7n+2jGhvRwBVW4E2KSrahqlnzLE585kgxg9k8C6TriC2bl7vdRojPicUjG9C0Or0UARV450A3jHqHKSr9mOM+amCwdlG+xpBCPVWwjrtFzpE7LQCB6+Tzs4JZDpFUU75CEMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1250!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142950347236"
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
  name           = "acctest-kce-230810142950347236"
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
  name                     = "sa230810142950347236"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230810142950347236"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230810142950347236"
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
