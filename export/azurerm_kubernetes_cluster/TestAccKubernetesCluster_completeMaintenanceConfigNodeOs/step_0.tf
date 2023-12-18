
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-231218071509753045"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks231218071509753045"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks231218071509753045"
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
    start_date   = "2023-12-18T00:00:00Z"

    not_allowed {
      end   = "2023-12-22T00:00:00Z"
      start = "2023-12-18T00:00:00Z"
    }
    not_allowed {
      end   = "2023-12-22T00:00:00Z"
      start = "2023-12-18T00:00:00Z"
    }
  }
}
