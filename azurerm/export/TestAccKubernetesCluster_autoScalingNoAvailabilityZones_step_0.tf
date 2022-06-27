
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220627131723464938"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220627131723464938"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220627131723464938"

  default_node_pool {
    name                = "pool1"
    min_count           = 1
    max_count           = 2
    enable_auto_scaling = true
    vm_size             = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
