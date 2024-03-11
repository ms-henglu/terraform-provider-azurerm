
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240311031710571537"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240311031710571537"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240311031710571537"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  maintenance_window_node_os {
    frequency = "AbsoluteMonthly"
    interval  = 1
    duration  = 9

    day_of_month = 5
    start_time   = "07:00"
    utc_offset   = "+01:00"
    start_date   = "2024-03-11T00:00:00Z"

    not_allowed {
      end   = "2024-03-15T00:00:00Z"
      start = "2024-03-11T00:00:00Z"
    }
    not_allowed {
      end   = "2024-03-15T00:00:00Z"
      start = "2024-03-11T00:00:00Z"
    }
  }
}
