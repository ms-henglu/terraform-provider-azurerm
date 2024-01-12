
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240112034116557907"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240112034116557907"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240112034116557907"
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
    start_date  = "2024-01-12T00:00:00Z"

    not_allowed {
      end   = "2024-01-16T00:00:00Z"
      start = "2024-01-12T00:00:00Z"
    }
    not_allowed {
      end   = "2024-01-16T00:00:00Z"
      start = "2024-01-12T00:00:00Z"
    }
  }
}
