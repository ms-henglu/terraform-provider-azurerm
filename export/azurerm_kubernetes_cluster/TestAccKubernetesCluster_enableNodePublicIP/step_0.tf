
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230915023140758043"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230915023140758043"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230915023140758043"

  default_node_pool {
    name                  = "default"
    node_count            = 1
    vm_size               = "Standard_DS2_v2"
    enable_node_public_ip = true
  }

  identity {
    type = "SystemAssigned"
  }
}
