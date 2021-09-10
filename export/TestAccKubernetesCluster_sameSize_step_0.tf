
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-210910021228808058"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks210910021228808058"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks210910021228808058"

  default_node_pool {
    name                = "default"
    node_count          = 1
    enable_auto_scaling = true
    vm_size             = "Standard_DS2_v2"
    min_count           = 1
    max_count           = 1
  }

  identity {
    type = "SystemAssigned"
  }
}
