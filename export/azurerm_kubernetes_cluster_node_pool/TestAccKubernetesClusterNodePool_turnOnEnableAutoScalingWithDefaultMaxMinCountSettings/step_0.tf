
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240119024742839644"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240119024742839644"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240119024742839644"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_kubernetes_cluster_node_pool" "test" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  vm_size               = "Standard_DS2_v2"
  enable_auto_scaling   = false
  min_count             = 0
  max_count             = 0
}
