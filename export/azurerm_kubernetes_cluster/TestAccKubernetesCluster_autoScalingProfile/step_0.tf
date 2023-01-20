
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230120051728613710"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230120051728613710"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230120051728613710"
  kubernetes_version  = "1.24.3"

  default_node_pool {
    name                = "default"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 4
    vm_size             = "Standard_DS2_v2"
  }

  auto_scaler_profile {
    skip_nodes_with_local_storage = false
  }

  identity {
    type = "SystemAssigned"
  }
}
