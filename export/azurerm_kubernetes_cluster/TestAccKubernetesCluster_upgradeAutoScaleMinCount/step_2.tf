
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-221111013305853394"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks221111013305853394"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks221111013305853394"
  kubernetes_version  = "1.23.12"

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
