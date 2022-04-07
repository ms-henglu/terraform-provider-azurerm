
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220407230819344242"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220407230819344242"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220407230819344242"

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
