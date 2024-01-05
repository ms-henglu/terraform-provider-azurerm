
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240105060517946376"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240105060517946376"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240105060517946376"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpipprefix240105060517946376"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  prefix_length       = 31
}

resource "azurerm_kubernetes_cluster_node_pool" "test" {
  name                     = "internal"
  kubernetes_cluster_id    = azurerm_kubernetes_cluster.test.id
  vm_size                  = "Standard_DS2_v2"
  node_count               = 1
  enable_node_public_ip    = true
  node_public_ip_prefix_id = azurerm_public_ip_prefix.test.id
}
