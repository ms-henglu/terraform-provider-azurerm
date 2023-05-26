
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230526084836055918"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230526084836055918"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230526084836055918"
  node_resource_group = "acctestRGAKS-230526084836055918"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
