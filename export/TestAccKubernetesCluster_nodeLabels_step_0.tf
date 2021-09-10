
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-210910021228805429"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks210910021228805429"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks210910021228805429"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    node_labels = {
      "key" = "value"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}
