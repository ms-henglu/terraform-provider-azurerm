
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230721014802850371"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230721014802850371"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230721014802850371"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_DS2_v2"
    scale_down_mode = "Delete"
  }

  identity {
    type = "SystemAssigned"
  }
}
