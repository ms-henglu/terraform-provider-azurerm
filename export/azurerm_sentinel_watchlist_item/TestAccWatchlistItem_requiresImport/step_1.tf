


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230707010928848786"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-230707010928848786"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}

resource "azurerm_sentinel_watchlist" "test" {
  name                       = "accTestWL-230707010928848786"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "test"
  item_search_key            = "k1"
}


resource "azurerm_sentinel_watchlist_item" "test" {
  watchlist_id = azurerm_sentinel_watchlist.test.id
  properties = {
    k1 = "v1"
  }
}


resource "azurerm_sentinel_watchlist_item" "import" {
  name         = azurerm_sentinel_watchlist_item.test.name
  watchlist_id = azurerm_sentinel_watchlist_item.test.watchlist_id
  properties   = azurerm_sentinel_watchlist_item.test.properties
}
