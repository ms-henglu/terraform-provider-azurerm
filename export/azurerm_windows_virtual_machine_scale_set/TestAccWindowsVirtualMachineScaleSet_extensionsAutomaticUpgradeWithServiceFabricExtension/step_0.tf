

locals {
  vm_name = "acctvm24"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031615676526"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031615676526"
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


provider "azurerm" {
  features {}
}

resource "azurerm_service_fabric_cluster" "test" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  reliability_level   = "Bronze"
  upgrade_mode        = "Automatic"
  vm_image            = "Windows"
  management_endpoint = "http://example:80"

  node_type {
    name                 = "backend"
    instance_count       = 3
    is_primary           = true
    client_endpoint_port = 2020
    http_endpoint_port   = 80
    durability_level     = "Bronze"
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "test" {
  name                     = local.vm_name
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Standard_F2"
  instances                = 1
  admin_username           = "adminuser"
  admin_password           = "P@ssword1234!"
  upgrade_mode             = "Automatic"
  enable_automatic_updates = false
  overprovision            = false

  automatic_os_upgrade_policy {
    disable_automatic_rollback  = true
    enable_automatic_os_upgrade = false
  }

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT0S"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }

  extension {
    name                       = "ServiceFabric"
    publisher                  = "Microsoft.Azure.ServiceFabric"
    type                       = "ServiceFabricNode"
    type_handler_version       = "1.1"
    auto_upgrade_minor_version = true

    settings = jsonencode({
      clusterEndpoint    = azurerm_service_fabric_cluster.test.cluster_endpoint
      nodeTypeRef        = "backend"
      dataPath           = "C:\\SvcFab"
      durabilityLevel    = "Bronze"
      enableParallelJobs = true
    })
  }
}
