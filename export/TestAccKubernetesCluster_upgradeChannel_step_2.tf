
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220415030317306005"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                      = "acctestaks220415030317306005"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  dns_prefix                = "acctestaks220415030317306005"
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
