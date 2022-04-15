
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220415030317304850"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220415030317304850"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220415030317304850"

  default_node_pool {
    name              = "default"
    node_count        = 1
    vm_size           = "Standard_D2s_v3"
    ultra_ssd_enabled = false
    zones             = ["1", "2", "3"]
  }

  identity {
    type = "SystemAssigned"
  }
}
