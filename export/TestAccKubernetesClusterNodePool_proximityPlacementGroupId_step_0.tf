
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220527024019332043"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220527024019332043"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220527024019332043"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-aks-220527024019332043"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags = {
    environment = "Production"
  }
}
resource "azurerm_kubernetes_cluster_node_pool" "test" {
  name                         = "internal"
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.test.id
  vm_size                      = "Standard_DS2_v2"
  node_count                   = 1
  proximity_placement_group_id = azurerm_proximity_placement_group.test.id
}
