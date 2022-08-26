
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220826002518896638"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220826002518896638"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220826002518896638"
  kubernetes_version  = "1.23.5"

  default_node_pool {
    name                 = "default"
    node_count           = 1
    vm_size              = "Standard_DS2_v2"
    orchestrator_version = "1.22.11"
  }

  identity {
    type = "SystemAssigned"
  }
}
