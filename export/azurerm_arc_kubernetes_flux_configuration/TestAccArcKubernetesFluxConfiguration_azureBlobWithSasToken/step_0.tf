
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060250585284"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060250585284"
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
  name                = "acctestpip-240105060250585284"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060250585284"
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
  name                            = "acctestVM-240105060250585284"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9253!"
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
  name                         = "acctest-akcc-240105060250585284"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2xA9p9tP1MFkglV5GyR3ZO2VVBg7Qha9LPyVhzE28I+mIFXyCU1aEPo9pw3eyRojMEIBVLyKC74bi9bIbnqbvJwByE+X2v0XTgaJfxJKxIYHjauQJRQ+sDUeInke/EP+CRQgxPTDKknlzq1BrLvcNJUoX9kHtPrUIYCO8eTMShDnF8cRz/RpeLOqxx10bOSodaPkBOgSysUvFARAamZM/O4TbVfMbXA3YR1YWadCq6RYnxBQKG8/ky9gBx5K4K7ERCxcfxfRkm4nAA9ieKd1PFVMJT2nppthAkPxCJFxyAPxfXfzf+L9Iyf+Oi7u6lphxArWzE+rm7PUUjklPJxIuiKc7OF67UB4GDmzNRhLeUgLFW6BlYhvXtWC1UvslvPkvtAQqL+AZgL/4mbkig77Zk+CrmclEN9mtzLvXAmNZ4VoWqtA4DpO1LQ0LOHqoNt60BpYpHM6C5w1u8yrWcUxgh35h5cS9SWyGilaq6kA0sjESQZO3oc6nwPZ+XtWIJMvE5wiiPVKtHRWVfw0tR+pr/e8TAClVTxZbyGJ4MU/eJUBZYdSSHrPSEkhzXATXPchYf9cNjwpAvXfIvdfHPmvsQPGEMEqjRTD/TeYsNUX1y3LihS4rQQbJkYpAW6Zp1shAt2L6beQglpc7QmeXPSP6g9wwIqDAefPXrG3NIxG3/8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9253!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060250585284"
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
  name           = "acctest-kce-240105060250585284"
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
  name                     = "sa240105060250585284"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240105060250585284"
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

  start  = "2024-01-04T06:02:50Z"
  expiry = "2024-01-07T06:02:50Z"

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
  name       = "acctest-fc-240105060250585284"
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
