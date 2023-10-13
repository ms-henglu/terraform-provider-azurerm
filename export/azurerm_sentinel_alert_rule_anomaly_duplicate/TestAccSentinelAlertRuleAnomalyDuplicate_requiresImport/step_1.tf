


provider "azurerm" {
  features {}
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231013044214580700"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231013044214580700"
  location = "West Europe"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


data "azurerm_sentinel_alert_rule_anomaly" "test" {
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "Potential data staging"
}

resource "azurerm_sentinel_alert_rule_anomaly_duplicate" "test" {
  display_name               = "acctest duplicate rule"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  built_in_rule_id           = data.azurerm_sentinel_alert_rule_anomaly.test.id
  enabled                    = true
  mode                       = "Flighting"
}


resource "azurerm_sentinel_alert_rule_anomaly_duplicate" "import" {
  display_name               = azurerm_sentinel_alert_rule_anomaly_duplicate.test.display_name
  log_analytics_workspace_id = azurerm_sentinel_alert_rule_anomaly_duplicate.test.log_analytics_workspace_id
  built_in_rule_id           = azurerm_sentinel_alert_rule_anomaly_duplicate.test.built_in_rule_id
  enabled                    = azurerm_sentinel_alert_rule_anomaly_duplicate.test.enabled
  mode                       = azurerm_sentinel_alert_rule_anomaly_duplicate.test.mode
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.test]
}
