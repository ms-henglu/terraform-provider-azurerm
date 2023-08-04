
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025444351179"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025444351179"
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
  name                = "acctestpip-230804025444351179"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025444351179"
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
  name                            = "acctestVM-230804025444351179"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3451!"
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
  name                         = "acctest-akcc-230804025444351179"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAusbzxie1rddcRhzDlORydl/qpsHuLLoAkbOn6DyQr6LQt2LSD6ad+6YBmaAhC5UaMlPxZWedC3fOw3u5dno/Oe8NctaP3ewJwZVhGMCy7D9KUFuiZlIpvMJMvQu+bUdu8ScrN+D7OZalGfcERCq9DRNdaKJDlDhNwh1kKHczSAs499bp5jFVjkK5fXrJmP2g90TSAsYd7OqZHwBMbnWxVbItJEWs5FE6AQNLJRsjdnYDl9xvBk7xTU4tnjgqvbYcM3d1FwMwUMzLqBhHeT1vGSwZMV3KNKDdiU1/6Bbfw9BvEaiu5MG1Ye0pUEbiyCqFRQd+oCWaDYNTMnd2GIsvzpXExRjgmVcGiCziVIKHb6fruyOPB6xcaIx9MLt5sp+qDPPeQq9/69RQ8nX1kA3Z/i9YWeCq4jufDkekezlGEYXR9l2qgijvLQLlAgSQp8vEtWk2mB6UWsHL/Wo2elplpnWHGUMiAzam5iC1Ak0abcHpBVocSOm9zPhabXtHAmbb/ckRfCLPDgPjD0R8LjETaSYETNmMXeAVoe8REsyMxVSGCwR/G5ny5e7oZfGeFJ7jXqec4UFojKC1KpEUnn2WwGxA/oMrE/5/tFsDTwupYQQd5lhTj3SPCumRfG8OeZ8Vth8uG9PQGr8+jxlw5LdZB4LzqVpGvFezd6YaWis3ztcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3451!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025444351179"
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
  name           = "acctest-kce-230804025444351179"
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
  name       = "acctest-fc-230804025444351179"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
