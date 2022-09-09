
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220909034040389524"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220909034040389524"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220909034040389524"

  default_node_pool {
    name                         = "default"
    node_count                   = 1
    type                         = "AvailabilitySet"
    vm_size                      = "Standard_DS2_v2"
    only_critical_addons_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }
}
