
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230602030327827515"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230602030327827515"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230602030327827515"

  default_node_pool {
    name               = "default"
    node_count         = 1
    vm_size            = "Standard_D2s_v3"
    message_of_the_day = "daily message"
    os_sku             = "Mariner"
    workload_runtime   = "KataMshvVmIsolation"
  }

  identity {
    type = "SystemAssigned"
  }
}
