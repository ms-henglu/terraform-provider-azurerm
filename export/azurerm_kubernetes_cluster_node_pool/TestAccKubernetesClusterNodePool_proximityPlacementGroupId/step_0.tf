
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-231218071509732984"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks231218071509732984"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks231218071509732984"
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
  name                = "acctestPPG-aks-231218071509732984"
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
