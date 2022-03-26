
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220326010315944966"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220326010315944966"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220326010315944966"

  default_node_pool {
    name              = "default"
    node_count        = 1
    vm_size           = "Standard_DS2_v2"
    fips_enabled      = true
    kubelet_disk_type = "OS"
  }

  identity {
    type = "SystemAssigned"
  }
}
