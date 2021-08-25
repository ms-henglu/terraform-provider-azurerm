


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-210825043235718510"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-210825043235718510"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


resource "azurerm_sentinel_data_connector_microsoft_cloud_app_security" "test" {
  name                       = "accTestDC-210825043235718510"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_data_connector_microsoft_cloud_app_security" "import" {
  name                       = azurerm_sentinel_data_connector_microsoft_cloud_app_security.test.name
  log_analytics_workspace_id = azurerm_sentinel_data_connector_microsoft_cloud_app_security.test.log_analytics_workspace_id
}
