
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230929064631552695"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230929064631552695"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230929064631552695"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  maintenance_window_auto_upgrade {
    frequency = "RelativeMonthly"
    interval  = 2
    duration  = 8

    day_of_week = "Monday"
    week_index  = "First"
    start_time  = "07:00"
    utc_offset  = "+01:00"
    start_date  = "2023-11-26T00:00:00Z"

    not_allowed {
      end   = "2023-11-30T00:00:00Z"
      start = "2023-11-26T00:00:00Z"
    }
    not_allowed {
      end   = "2023-12-30T00:00:00Z"
      start = "2023-12-26T00:00:00Z"
    }
  }
}
