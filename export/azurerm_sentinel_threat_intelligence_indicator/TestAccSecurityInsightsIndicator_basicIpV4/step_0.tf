
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231218072513898898"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231218072513898898"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
}


resource "azurerm_sentinel_threat_intelligence_indicator" "test" {
  workspace_id      = azurerm_log_analytics_workspace.test.id
  pattern_type      = "ipv4-addr"
  pattern           = "1.1.1.1"
  source            = "Microsoft Sentinel"
  validate_from_utc = "2022-12-14T16:00:00Z"
  display_name      = "test"

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.test]
}
