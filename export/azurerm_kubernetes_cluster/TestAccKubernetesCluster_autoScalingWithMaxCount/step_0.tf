
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-AKS-231016033638257090"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestAKS231016033638257090"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestAKS231016033638257090"

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_DS2_v2"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 1000
    node_count          = 1
  }

  identity {
    type = "SystemAssigned"
  }
}
