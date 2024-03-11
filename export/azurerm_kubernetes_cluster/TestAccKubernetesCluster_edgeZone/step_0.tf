
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240311031710587158"
  location = "westus"
}
data "azurerm_extended_locations" "test" {
  location = azurerm_resource_group.test.location
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240311031710587158"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240311031710587158"
  kubernetes_version  = "1.29.0"
  run_command_enabled = true
  edge_zone           = data.azurerm_extended_locations.test.extended_locations[0]
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  tags = {
    ENV = "Test1"
  }
}
  