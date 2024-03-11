
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240311031710560395"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctestasg-240311031710560395"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240311031710560395"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240311031710560395"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "test" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  vm_size               = "Standard_D2s_v3"
  enable_node_public_ip = true
  node_network_profile {
    allowed_host_ports {
      port_start = 8001
      port_end   = 8002
      protocol   = "UDP"
    }
    application_security_group_ids = [azurerm_application_security_group.test.id]
    node_public_ip_tags = {
      RoutingPreference = "Internet"
    }
  }
}
 