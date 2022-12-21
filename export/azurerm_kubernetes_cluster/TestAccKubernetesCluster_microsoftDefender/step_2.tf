
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-221221204115078408"
  location = "West Europe"
}
resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-221221204115078408"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                              = "acctestaks221221204115078408"
  location                          = azurerm_resource_group.test.location
  resource_group_name               = azurerm_resource_group.test.name
  dns_prefix                        = "acctestaks221221204115078408"
  role_based_access_control_enabled = true
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
}
