
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220527024019337048"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220527024019337048"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220527024019337048"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  maintenance_window {
    not_allowed {
      end   = "2021-11-30T12:00:00Z"
      start = "2021-11-26T03:00:00Z"
    }
    not_allowed {
      end   = "2021-12-30T12:00:00Z"
      start = "2021-12-26T03:00:00Z"
    }
    allowed {
      day   = "Monday"
      hours = [1, 2]
    }
    allowed {
      day   = "Sunday"
      hours = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
    }
  }
}
