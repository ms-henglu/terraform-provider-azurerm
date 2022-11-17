

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-221117231101695305"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-221117231101695305"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


resource "azurerm_log_analytics_datasource_windows_event" "test" {
  name                = "acctestLADS-WE-221117231101695305"
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
  event_log_name      = "Application"
  event_types         = ["Error"]
}
