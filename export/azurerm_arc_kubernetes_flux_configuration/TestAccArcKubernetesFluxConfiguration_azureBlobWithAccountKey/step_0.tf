
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025448347924"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025448347924"
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
  name                = "acctestpip-230804025448347924"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025448347924"
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
  name                            = "acctestVM-230804025448347924"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4041!"
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
  name                         = "acctest-akcc-230804025448347924"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAs1xWH1awr+NtV1mIoKm+FgO8AfiImu6IOkYvfIeXoWNJUVYyCsz2h/bsGB3HtigSFu4a234gk5GQXoaUU+j+cG09g3MUfh7AUx9+FRvz1Lpvf0KJkrLepQBrCwTYGtc7s2wDLdupWx6Rvqa421FGElC4Ex10UTh6JRA8YaDuKaBh1SrzL2tOlVZeJCewblcgCdAaTF7XKwnTOAAs7xFUU5odKSdzrxWW29oHNEShhEc5UIkLeopzr1+eEVjvMZGuQEW0Bjh31y7zeGqfVtEnGBlTIoU5zSjxNnV7seF06+wOACTkbxP5JHd5h63jI86a8A1If30neK3FSz8M33+6o0flLxYr6PSBysk/7qZ8gV8aph+z5b073d+jgKydPUd4TbBbmYXLX8uDGVe4EmIsoCWzUen8BIYmGN4EvLKzw2Rkm/fVNarDz8YicLuJG3K/du8uhNuY05NyRzL/yLseDqbXkJQ5jt+sWGKCv/OMw9bRnQXXxqPUXOSyxE/Hm6WVADLAK2FkTUWJxLSbqFtiVncuNtxDNrO0FgzhU08zElxFTgY/updlAFfkiYmy4w6bTiAfAIp/mtI3uylJMBSQJwF1deGNJBEpfLkZhxylba7XsIPiJKSYHCcL4at9Q2361FmriU00Qd+zRoTq4J7p1bmmISxS8bjUfRLxY+goDs8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4041!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025448347924"
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
  name           = "acctest-kce-230804025448347924"
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
  name                     = "sa230804025448347924"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230804025448347924"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230804025448347924"
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
