
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240315122643966802"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240315122643966802"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240315122643966802"

  default_node_pool {
    name         = "default"
    node_count   = 1
    vm_size      = "Standard_NC24ads_A100_v4"
    gpu_instance = "MIG1g"
  }

  identity {
    type = "SystemAssigned"
  }
}
  