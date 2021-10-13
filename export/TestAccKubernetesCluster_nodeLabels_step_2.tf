
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-211013071655571303"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks211013071655571303"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks211013071655571303"

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
