
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122334453540"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122334453540"
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
  name                = "acctestpip-240315122334453540"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122334453540"
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
  name                            = "acctestVM-240315122334453540"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1540!"
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
  name                         = "acctest-akcc-240315122334453540"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA9/4o1hgCK+cIOHhlWzFNZMgW+8SbRb4x64EicFF2ngdZwy9AdXPaI7vpUs2HuD35D3+KWlFC4lf0b8gyE10Z4P57WCJWoscHoTv1f44kRdqWAI+dgkYzutlDpEJA+dlplwvClp/Kb/x3/5YVs/LJ2xk8Mz95Fm1RfL3moqunO7Sx1pHPtS3bm6t76EbZ3UiSx4Q6nlKy+x8NdsGlmhArdqz6fCSkiYbESdSy/vKBYoZPEGe9V0A6PuBIbLjztg1bmh3VtaC+5xnw/aQqIjed+zvY7gA9vaSGrdj58Eq0hCDY+YlB0ydF9Ju+TN2Pm9bZ4nD6yxUajlp+Pvez6ED4BqdDcifMiAKfhQzm/4WKbsJGJXqOrVkYH/VF+Crzdzu5o0IQincwyOJyYp+Goq1pm1KBesh4PPKDt9N2Iup4VLis6kgGWrLR1SspmKeob55f3QSJV0ZEXnrFcVCfC6ZKqjmGDx/lUXaHa/yPIr5jNsNsyE9NHt9W6ug3QBBczo+XQoRVmMo5IH6RakL+D5tICc0OVAQH7pXD1h3+EAjcR4sNEDPTQz3ZCkTL0zfsLiVIQkf+Qf6vguH+R8vkLnJ/C7Cz0yn9UfBvb5w4gujyb0nF2PyKpBAGkt1gWMR1Voyq+WbbVDyLCXz30sJnsSn2Idu+Fjkr0X7IRLHBlpgngvsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1540!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122334453540"
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
  name           = "acctest-kce-240315122334453540"
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
  name                     = "sa240315122334453540"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240315122334453540"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  https_only        = true
  signed_version    = "2019-10-10"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2024-03-14T12:23:34Z"
  expiry = "2024-03-17T12:23:34Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = false
  }
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240315122334453540"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    sas_token    = data.azurerm_storage_account_sas.test.sas
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
