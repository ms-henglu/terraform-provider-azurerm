
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230630032924570526"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230630032924570526"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230630032924570526"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  network_profile {
    network_plugin = "kubenet"
    dns_service_ip = "10.1.1.10"
    service_cidrs  = ["10.1.1.0/24", "2002::1234:abcd:ffff:c0a8:101/120"]
    ip_versions    = ["IPv4", "IPv6"]
  }

  identity {
    type = "SystemAssigned"
  }
}
