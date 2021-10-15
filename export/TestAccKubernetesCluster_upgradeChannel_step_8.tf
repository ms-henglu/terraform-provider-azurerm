
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-211015014444976441"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                      = "acctestaks211015014444976441"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  dns_prefix                = "acctestaks211015014444976441"
  kubernetes_version        = "1.20.9"
  automatic_channel_upgrade = "stable"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_DS2_v2"
    node_count = 1
  }

  identity {
    type = "SystemAssigned"
  }
}
