
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220527033959190447"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220527033959190447"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220527033959190447"
  kubernetes_version  = "1.21.7"

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_DS2_v2"
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 8
  }

  identity {
    type = "SystemAssigned"
  }
}
