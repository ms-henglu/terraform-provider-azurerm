
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240119024742854264"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "source" {
  name                = "acctestaks240119024742854264"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240119024742854264"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
}
