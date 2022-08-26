
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002921118525"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                       = "acctestLAW-220826002921118525"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  internet_ingestion_enabled = true
  sku                        = "PerGB2018"
  retention_in_days          = 30
}
