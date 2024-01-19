
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240119024742822664"
  location = "West Europe"
}
resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024742822664"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_subnet" "nodesubnet" {
  name                 = "nodesubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.240.0.0/16"]
}
resource "azurerm_subnet" "podsubnet" {
  name                 = "podsubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.241.0.0/16"]
  delegation {
    name = "aks-delegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240119024742822664"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240119024742822664"
  sku_tier            = "Standard"
  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    pod_subnet_id  = azurerm_subnet.podsubnet.id
    vnet_subnet_id = azurerm_subnet.nodesubnet.id
  }
  network_profile {
    network_plugin = "azure"
  }
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_kubernetes_cluster_node_pool" "test" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  pod_subnet_id         = azurerm_subnet.podsubnet.id
  vnet_subnet_id        = azurerm_subnet.nodesubnet.id
}
