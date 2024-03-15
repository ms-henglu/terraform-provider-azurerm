
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240315124013506436"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240315124013506436"
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
  pattern_type      = "domain-name"
  pattern           = "http://test.com"
  source            = "Microsoft Sentinel"
  validate_from_utc = "2022-12-14T16:00:00Z"
  display_name      = "test"

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.test]
}


resource "azurerm_sentinel_threat_intelligence_indicator" "import" {
  workspace_id      = azurerm_sentinel_threat_intelligence_indicator.test.workspace_id
  pattern_type      = azurerm_sentinel_threat_intelligence_indicator.test.pattern_type
  pattern           = azurerm_sentinel_threat_intelligence_indicator.test.pattern
  source            = azurerm_sentinel_threat_intelligence_indicator.test.source
  validate_from_utc = azurerm_sentinel_threat_intelligence_indicator.test.validate_from_utc
  display_name      = azurerm_sentinel_threat_intelligence_indicator.test.display_name
}
