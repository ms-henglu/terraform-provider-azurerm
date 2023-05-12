
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230512010437951005"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230512010437951005"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230512010437951005"
  kubernetes_version  = "1.25.5"

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
  