
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230825024306186861"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230825024306186861"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230825024306186861"
  default_node_pool {
    name                  = "default"
    node_count            = 1
    vm_size               = "Standard_DS2_v2"
    enable_node_public_ip = true
    node_network_profile {
      node_public_ip_tags = {
        RoutingPreference = "Internet"
      }
    }
  }
  identity {
    type = "SystemAssigned"
  }
}
 