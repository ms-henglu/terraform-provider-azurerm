
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-211001020621449490"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks211001020621449490"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks211001020621449490"
  kubernetes_version  = "1.19.11"

  default_node_pool {
    name                 = "default"
    node_count           = 1
    vm_size              = "Standard_DS2_v2"
    orchestrator_version = "1.18.19"
  }

  identity {
    type = "SystemAssigned"
  }
}
