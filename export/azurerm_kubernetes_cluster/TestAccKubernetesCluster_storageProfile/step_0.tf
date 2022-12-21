
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-221221204115072688"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks221221204115072688"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks221221204115072688"
  kubernetes_version  = "1.24.3"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  storage_profile {
    blob_driver_enabled         = true
    disk_driver_enabled         = true
    disk_driver_version         = "v1"
    file_driver_enabled         = false
    snapshot_controller_enabled = false
  }
}
  