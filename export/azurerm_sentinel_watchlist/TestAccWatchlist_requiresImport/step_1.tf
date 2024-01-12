


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-240112035116031820"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-240112035116031820"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}




resource "azurerm_sentinel_watchlist" "test" {
  name                       = "accTestWL-240112035116031820"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "test"
  item_search_key            = "Key"
}


resource "azurerm_sentinel_watchlist" "import" {
  name                       = azurerm_sentinel_watchlist.test.name
  log_analytics_workspace_id = azurerm_sentinel_watchlist.test.log_analytics_workspace_id
  display_name               = azurerm_sentinel_watchlist.test.display_name
  item_search_key            = azurerm_sentinel_watchlist.test.item_search_key
}
