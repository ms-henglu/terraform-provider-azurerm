
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230818023753528840"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "source" {
  name                = "acctestaks230818023753528840"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230818023753528840"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_kubernetes_node_pool_snapshot" "test" {
  name                = "pjf4z"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230818023753528840new"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230818023753528840new"
  default_node_pool {
    name        = "default"
    node_count  = 1
    vm_size     = "Standard_DS2_v2"
    snapshot_id = data.azurerm_kubernetes_node_pool_snapshot.test.id
  }
  identity {
    type = "SystemAssigned"
  }
}
