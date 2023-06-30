
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230630032924580730"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230630032924580730"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230630032924580730"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_kubernetes_cluster_node_pool" "test" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  vm_size               = "Standard_D2s_v3"
  workload_runtime      = "OCIContainer"
}
