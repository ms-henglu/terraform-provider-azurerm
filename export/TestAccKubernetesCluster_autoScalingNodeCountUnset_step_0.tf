
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220811053040718139"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220811053040718139"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220811053040718139"

  default_node_pool {
    name                = "default"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 4
    vm_size             = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
