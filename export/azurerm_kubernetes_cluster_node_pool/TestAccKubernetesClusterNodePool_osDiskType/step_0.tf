
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240119024742821468"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240119024742821468"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240119024742821468"

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
  vm_size               = "Standard_DS3_v2"
  node_count            = 1
  os_disk_size_gb       = 100
  os_disk_type          = "Ephemeral"
}
