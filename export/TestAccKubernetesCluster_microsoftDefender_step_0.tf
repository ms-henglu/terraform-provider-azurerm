
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-220627124005901680"
  location = "West Europe"
}
resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-220627124005901680"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                              = "acctestaks220627124005901680"
  location                          = azurerm_resource_group.test.location
  resource_group_name               = azurerm_resource_group.test.name
  dns_prefix                        = "acctestaks220627124005901680"
  role_based_access_control_enabled = true
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
}
