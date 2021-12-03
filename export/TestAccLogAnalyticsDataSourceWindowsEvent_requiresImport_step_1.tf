


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-211203014015468668"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-211203014015468668"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


resource "azurerm_log_analytics_datasource_windows_event" "test" {
  name                = "acctestLADS-WE-211203014015468668"
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
  event_log_name      = "Application"
  event_types         = ["error"]
}


resource "azurerm_log_analytics_datasource_windows_event" "import" {
  name                = azurerm_log_analytics_datasource_windows_event.test.name
  resource_group_name = azurerm_log_analytics_datasource_windows_event.test.resource_group_name
  workspace_name      = azurerm_log_analytics_datasource_windows_event.test.workspace_name
  event_log_name      = azurerm_log_analytics_datasource_windows_event.test.event_log_name
  event_types         = azurerm_log_analytics_datasource_windows_event.test.event_types
}
