
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220121044333454518"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                      = "acctestaks220121044333454518"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  dns_prefix                = "acctestaks220121044333454518"
  kubernetes_version        = "1.20.9"
  automatic_channel_upgrade = "node-image"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_DS2_v2"
    node_count = 1
  }

  identity {
    type = "SystemAssigned"
  }
}
