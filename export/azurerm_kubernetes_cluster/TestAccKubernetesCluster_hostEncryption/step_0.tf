
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-221111013305857191"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks221111013305857191"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks221111013305857191"
  kubernetes_version  = "1.24.3"

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
  