
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220527033959194973"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220527033959194973"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220527033959194973"
  kubernetes_version  = "1.22.4"

  default_node_pool {
    name                   = "default"
    node_count             = 1
    vm_size                = "Standard_DS2_v2"
    enable_host_encryption = true
  }

  identity {
    type = "SystemAssigned"
  }
}
  