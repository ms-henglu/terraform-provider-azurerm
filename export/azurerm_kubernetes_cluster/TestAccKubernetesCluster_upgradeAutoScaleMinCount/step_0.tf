
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230407023134949411"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230407023134949411"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230407023134949411"
  kubernetes_version  = "1.24.9"

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_DS2_v2"
    enable_auto_scaling = true
    min_count           = 4
    max_count           = 8
  }

  identity {
    type = "SystemAssigned"
  }
}
