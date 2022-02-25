
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225034611368191"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                       = "acctestLAW-220225034611368191"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  internet_ingestion_enabled = false
  sku                        = "PerGB2018"
  retention_in_days          = 30
}
