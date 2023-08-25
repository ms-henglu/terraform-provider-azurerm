
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230825024306208576"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "source" {
  name                = "acctestaks230825024306208576"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230825024306208576"
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
  name                = "aazgr"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230825024306208576new"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230825024306208576new"
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
