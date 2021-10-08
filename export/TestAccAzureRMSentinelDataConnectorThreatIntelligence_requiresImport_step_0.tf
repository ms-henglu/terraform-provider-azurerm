

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-211008044922087125"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-211008044922087125"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


resource "azurerm_sentinel_data_connector_threat_intelligence" "test" {
  name                       = "accTestDC-211008044922087125"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}
