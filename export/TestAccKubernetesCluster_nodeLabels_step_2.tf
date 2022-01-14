
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220114014031001540"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220114014031001540"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220114014031001540"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    node_labels = {

    }
  }

  identity {
    type = "SystemAssigned"
  }
}
