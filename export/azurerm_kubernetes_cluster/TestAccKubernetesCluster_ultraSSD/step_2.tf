
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230203063101432324"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230203063101432324"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230203063101432324"

  default_node_pool {
    name              = "default"
    node_count        = 1
    vm_size           = "Standard_D2s_v3"
    ultra_ssd_enabled = true
    zones             = ["1", "2", "3"]
  }

  identity {
    type = "SystemAssigned"
  }
}
