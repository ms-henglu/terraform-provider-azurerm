


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-220627134949049977"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-220627134949049977"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


resource "azurerm_sentinel_data_connector_threat_intelligence" "test" {
  name                       = "accTestDC-220627134949049977"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_data_connector_threat_intelligence" "import" {
  name                       = azurerm_sentinel_data_connector_threat_intelligence.test.name
  log_analytics_workspace_id = azurerm_sentinel_data_connector_threat_intelligence.test.log_analytics_workspace_id
}
