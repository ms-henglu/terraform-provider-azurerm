
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230922060849045682"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230922060849045682"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230922060849045682"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  network_profile {
    network_plugin = "kubenet"
    dns_service_ip = "10.1.1.10"
    service_cidrs  = ["10.1.1.0/24"]
  }

  identity {
    type = "SystemAssigned"
  }
}
