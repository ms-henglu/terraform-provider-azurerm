
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220610022401083415"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                      = "acctestaks220610022401083415"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  dns_prefix                = "acctestaks220610022401083415"
  kubernetes_version        = "1.21.7"
  automatic_channel_upgrade = "patch"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_DS2_v2"
    node_count = 1
  }

  identity {
    type = "SystemAssigned"
  }
}
