
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072030977946"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                                    = "acctestLAW-231218072030977946"
  location                                = azurerm_resource_group.test.location
  resource_group_name                     = azurerm_resource_group.test.name
  sku                                     = "PerGB2018"
  retention_in_days                       = 30
  immediate_data_purge_on_30_days_enabled = true
}
