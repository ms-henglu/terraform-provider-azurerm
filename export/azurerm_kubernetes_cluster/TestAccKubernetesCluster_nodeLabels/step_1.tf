
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230421021917829708"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230421021917829708"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230421021917829708"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    node_labels = {
      "key2" = "value2"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}
