
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021541703601"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021541703601"
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
  name                = "acctestpip-240119021541703601"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021541703601"
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
  name                            = "acctestVM-240119021541703601"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3214!"
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
  name                         = "acctest-akcc-240119021541703601"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwL1l5gViCYNIGZuu/t32PZc6/C0VamQ4Y+sVnLsGsgnW2kRTWUwSPSmV4z9nYWEA1BRuMIWNfRq+eelTr5m4nH0MStKWJnXZB72xtXdMEcAKOGIlweo9rdRCXlN4Bi6hsqQ0n99SLH0iVIJBwP86P4cWihtiOddh2TEKfprOhyu2HlolBLU7r04rZCbOBaI9ogA9mt+IjF8+TyOK0MUULaR7zOmoYQKLpf06gLxe+Pj0f36q09nS1N4iKYWz1V+tfj1rz6BQocsOFvxtg3I4boWkdTiI46Pj0E7BqcW1MwU+Rd4a+vcr2ukP2r+tOA+MvV1vk2ergFgr/rmvKTWNye+FtebdqEMvdexgU10G+KwgV7sulCdbhiOhhicSRqUR0HnVNeRaB0lD0tA/ta1o59FbmQ/LLF4oOxiYZZrqZs2CdwwPW6EYuQh9TDDKPF5TUJxoLG8cH1VYXNAsdjoIfoJLCzNYCWD9vqo5AWXu0offvbbvSMI4pE2f2xiG2J5Al2mkPn+3S/4/ABkpc7u5awXKQFdVj7D+fCl+6ay0agm4kldPfTKqp29JB/QqLg9c/J0EvGdKMjOiSDKRpY3S2DedPtQrJTJhiZKdnyIV+S6AbveUEp7/D1LJqSan9aAam3cBgtNOwWoVXy3TYCaC3py7fHM9biOxOhvChrgnPFMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3214!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021541703601"
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
  name           = "acctest-kce-240119021541703601"
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
  name                     = "sa240119021541703601"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240119021541703601"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240119021541703601"
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
