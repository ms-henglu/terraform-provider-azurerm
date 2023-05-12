
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230512010437951343"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230512010437951343"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230512010437951343"
  kubernetes_version  = "1.24.9"

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_DS2_v2"
    enable_auto_scaling = true
    min_count           = 5
    max_count           = 8
  }

  identity {
    type = "SystemAssigned"
  }
}
