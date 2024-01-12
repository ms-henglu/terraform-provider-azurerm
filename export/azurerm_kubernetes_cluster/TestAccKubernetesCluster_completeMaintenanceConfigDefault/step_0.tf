
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240112034116551566"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240112034116551566"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240112034116551566"
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
      end   = "2021-11-29T12:00:00Z"
      start = "2021-11-26T03:00:00Z"
    }
    not_allowed {
      end   = "2021-12-29T12:00:00Z"
      start = "2021-12-26T03:00:00Z"
    }
    allowed {
      day   = "Monday"
      hours = [1, 2]
    }
    allowed {
      day   = "Thursday"
      hours = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
    }
    allowed {
      day   = "Friday"
      hours = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
    }
    allowed {
      day   = "Saturday"
      hours = [10, 11, 12, 13, 14, 15, 16]
    }
  }
}
