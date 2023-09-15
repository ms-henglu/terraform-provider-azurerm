
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022912724810"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022912724810"
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
  name                = "acctestpip-230915022912724810"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022912724810"
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
  name                            = "acctestVM-230915022912724810"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4920!"
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
  name                         = "acctest-akcc-230915022912724810"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxBqaQNmIzganwhZ7FuM6oX4Qo8P0SvtbKxy8CZDWGmvjmfiEFjR0qRe5ISScP7KhxZHxRUDy3P4bt8XHSwEPcfdOmoklDhU9C3BAnJxQOqbJeGWEY6RuxjCjwmhRK+ySfbPPe5Un/yxRz9c/ONanJFb1aSgbmvjTfdY52lOtFFTBWWXRPsZmvASRVVONl1HKmza77w6hkRYjsMcfIg7vHghgddsibcpyg/+V+xFQ5Anbq9qt4RZazTd6tj7epEZff1oO2WQtb0GJU4CzLUXBKLXtdoRaUkB0YWqNNjrcDtoTmeO0n6WKrWKcTfBvHHeMTRYgSP1hx2T+gxLWxTHHaQ6iDzIPKkWvGgezvahcQH5pEEn60e3jQsuQynHIt47s4Mu1cHNQe4MEs77k6aincz9IAcEODDxKPpEGRAN9qdn2CeZ9NiJSbxDVf2YQVwb++qx/K4YRAUMR50ZQdiDSYDI/MWi9P1ZaxO+EjIAK7zaduyD4g4/aEKGqSP5/C60hgvQ2zufnd7Fbyxx3mnagS8/wf8FhOdB+cXuDI7HpM7v4ihy/Dk8eu0ZOyxQKBHrWnxX6XdyrZI/T1LVDzxkgAMpHLb3ZYWaOAuGQBupPvNHiZoROFya1LMZntJLADv2I02JRoXQyr5I0P5MTWTIQ7HcDlPgTssRdK7xTZQgjAfkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4920!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022912724810"
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
  name           = "acctest-kce-230915022912724810"
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
  name                     = "sa230915022912724810"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230915022912724810"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230915022912724810"
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
