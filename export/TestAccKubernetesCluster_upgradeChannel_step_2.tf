
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-211001020621433053"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                      = "acctestaks211001020621433053"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  dns_prefix                = "acctestaks211001020621433053"
  kubernetes_version        = "1.18.19"
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
