
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-231013043207717761"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks231013043207717761"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks231013043207717761"

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
