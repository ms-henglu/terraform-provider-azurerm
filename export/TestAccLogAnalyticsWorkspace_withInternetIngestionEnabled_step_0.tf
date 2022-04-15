
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415030715717952"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                       = "acctestLAW-220415030715717952"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  internet_ingestion_enabled = true
  sku                        = "PerGB2018"
  retention_in_days          = 30
}
