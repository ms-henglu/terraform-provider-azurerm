
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071242840007"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071242840007"
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
  name                = "acctestpip-231218071242840007"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071242840007"
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
  name                            = "acctestVM-231218071242840007"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6543!"
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
  name                         = "acctest-akcc-231218071242840007"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA7MF6uDR518nKQBqNwINBMOPkYBmnXNZnKmsudiZVutcvAbtETo2Ecq6IKqlgS1OP5diNpU/IdXR3ZQXxh2KoUi8EWAzfZhHXlSfSIZxbhhV1YJTilyYXYa/rnFxK2ZdS717edb/KCHnsZCCZtwc7AwgFCOqW5Vo6VFeyHojVfaRg0ENAjmKxU1dEaZ3fSfdHZpHA4XlVKSm4AlWlrh1zc92Kg/1VoFW/Bh8JdgNtTf5XoZrCFyZvVRSSjsLQnkdvKIjDspW4G51fV8qPMecceAMv6uWoQFn8OaPhCa4hfikvtOwiaCp26AB9i2ExcRttoOEJqWWu4zNrkfUVHOt1ni4CTiol/BZdTpHsaliJUY20iQCec8EWUcDwLzHNGZUONam1reDZYGrIq+uZ3NzG3YzOXKUH2lfoXJZryb1vXEvV/cxotdSBa4YBW0IAXicL5bRl6VsftfRCZYDz8QUpSpwq026cJC1sE+HAQY3/4fM6NUWGZltsk930vKP7wbcOJPVh1xc98geF0CSAkQvcZW8AqSAYGU62pvIJuPm61zoCYBdUPm3T2YfTv14AKQvPZvafdutBGkxJdFz3z43w3SAOgVsbLp0CFOL0eUx9Gu73CO6DFUjxVnnwW6xJsVXp/udDMZiUoXPUXoyEUqCY8oBl5sXInTGPEeOZ2UWOcZsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6543!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071242840007"
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
  name           = "acctest-kce-231218071242840007"
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
  name                     = "sa231218071242840007"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231218071242840007"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-231218071242840007"
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
