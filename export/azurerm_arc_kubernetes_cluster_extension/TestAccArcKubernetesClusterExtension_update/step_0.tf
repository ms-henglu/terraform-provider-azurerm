
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071222663486"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071222663486"
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
  name                = "acctestpip-231218071222663486"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071222663486"
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
  name                            = "acctestVM-231218071222663486"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9199!"
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
  name                         = "acctest-akcc-231218071222663486"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0q3hGkjVW3OZasqRvdlyBnWvxGCLy1oIwvZqR6BUChSwG9lhpEt7ImTWkMx3+1P4YE13m7CoOxIKpwJO7B30nLcZC7Lr4tMuKaaGSfnDzJd3CY5L1cfA8t8G7MkT2/Z65bY0aBxR7vNgcmR2mDQCjMEdLbm4xZvKvL5CKDgt3dnnEBu+sLRu0ssjq5QQ+OpOwnykKn3I0AlKac/TEJLLwVGcsnKf90jKQJlWlk3Qs2AjnZy4qCkttMSo5zy2hOk51bdYU4zFU11AJf90gYCRtTMKtDInlfUnxFXuKZ9b6E0cz9CBp3oBtPdDa40IDGBUqKsKPs4jxR/mNI0MLSyHH8IS2rXF45/k4TADw55h988VFkxBAcBHHjJCDuX7BwIIJ7gM839fxaGWd6AvL/76r5ZJVFCfnGA07CD4ehd392ImTY2uH5s2IrQDrARKCE5swjGhB4NROJ2M6vy6LTclzauaxg+O5uQSLY9gAYHh2p+OA5J5AlxAf7wS27PRfOw344MoH+sRaJUCEiNNnluKFO7xrTmThRlfKk5YGo7Qbvu4X9DVnvoHIZ869QNQgUhR9S03Fg3W8tKwNsPVfscz40lWVGq5LovMVtQhxof+qXcuH1pNTNEPtxBO7Jl432pT20ZSjpbTwgwQPcA3j/G2ipWL9I8mfQ/P7Arijc4jag0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9199!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071222663486"
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
  name              = "acctest-kce-231218071222663486"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  release_train     = "stable"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
