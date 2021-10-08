
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-211008044217885247"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks211008044217885247"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks211008044217885247"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
    os_sku     = "Ubuntu"
  }
  identity {
    type = "SystemAssigned"
  }
}
