
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-210825044619486386"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks210825044619486386"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks210825044619486386"
  default_node_pool {
    name               = "default"
    node_count         = 1
    vm_size            = "Standard_D2s_v3"
    ultra_ssd_enabled  = false
    availability_zones = ["1", "2", "3"]
  }
  identity {
    type = "SystemAssigned"
  }
}
