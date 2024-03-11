


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311031710609899"
  location = "West Europe"
}

resource "azurerm_kubernetes_fleet_manager" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestkfm-240311031710609899"
  resource_group_name = azurerm_resource_group.test.name
  hub_profile {
    dns_prefix = "val-240311031710609899"
  }
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestkc-240311031710609899"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestkc-240311031710609899"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_fleet_member" "test" {
  name                  = "acctestkfm-240311031710609899"
  kubernetes_fleet_id   = azurerm_kubernetes_fleet_manager.test.id
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  group                 = "acctestfus-240311031710609899"
}

resource "azurerm_kubernetes_fleet_update_strategy" "test" {
  name                        = "acctestfus-240311031710609899"
  kubernetes_fleet_manager_id = azurerm_kubernetes_fleet_manager.test.id
  stage {
    name = "acctestfus-240311031710609899"
    group {
      name = "acctestfus-240311031710609899"
    }
  }
}


resource "azurerm_kubernetes_fleet_update_run" "test" {
  name                        = "acctestfus-240311031710609899"
  kubernetes_fleet_manager_id = azurerm_kubernetes_fleet_manager.test.id
  managed_cluster_update {
    upgrade {
      type = "NodeImageOnly"
    }
  }
  fleet_update_strategy_id = azurerm_kubernetes_fleet_update_strategy.test.id

  lifecycle {
    ignore_changes = [stage]
  }
  depends_on = [azurerm_kubernetes_fleet_member.test]
}
