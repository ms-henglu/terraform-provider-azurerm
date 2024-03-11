

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-240311033049080425"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-240311033049080425"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}

resource "azurerm_sentinel_watchlist" "test" {
  name                       = "accTestWL-240311033049080425"
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
