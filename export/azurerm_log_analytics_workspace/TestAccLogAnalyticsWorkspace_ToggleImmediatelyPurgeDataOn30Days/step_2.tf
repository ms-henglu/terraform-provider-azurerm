
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061032769373"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                                    = "acctestLAW-240105061032769373"
  location                                = azurerm_resource_group.test.location
  resource_group_name                     = azurerm_resource_group.test.name
  sku                                     = "PerGB2018"
  retention_in_days                       = 30
  immediate_data_purge_on_30_days_enabled = true
}
