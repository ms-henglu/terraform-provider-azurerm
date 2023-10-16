
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034159743005"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                 = "acctestLAW-231016034159743005"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  sku                  = "PerGB2018"
  retention_in_days    = 30
  cmk_for_query_forced = true
}
