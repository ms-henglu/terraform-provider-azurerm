

provider "azurerm" {
  features {}
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230316222243322131"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230316222243322131"
  location = "West Europe"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
}

resource "azurerm_sentinel_alert_rule_anomaly_built_in" "test" {
  display_name               = "UEBA Anomalous Sign In"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  enabled                    = true
  mode                       = "Production"
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.test]
}
