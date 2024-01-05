
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240105060517959279"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240105060517959279"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240105060517959279"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "source" {
  name                  = "source"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  vm_size               = "Standard_D2s_v3"
}

data "azurerm_kubernetes_node_pool_snapshot" "test" {
  name                = "le3jx"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_kubernetes_cluster_node_pool" "test" {
  name                  = "new"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  snapshot_id           = data.azurerm_kubernetes_node_pool_snapshot.test.id
  depends_on = [
    azurerm_kubernetes_cluster_node_pool.source
  ]
}
 