
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034336831137"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                   = "acctestLAW-220527034336831137"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  internet_query_enabled = true
  sku                    = "PerGB2018"
  retention_in_days      = 30
}
