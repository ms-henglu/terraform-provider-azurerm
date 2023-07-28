

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230728030631118316"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230728030631118316"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


data "azurerm_sentinel_alert_rule_template" "test" {
  display_name               = "(Preview) Anomalous SSH Login Detection"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
}

resource "azurerm_sentinel_alert_rule_machine_learning_behavior_analytics" "test" {
  name                       = "acctest-SentinelAlertRule-MLBehaviorAnalytics-230728030631118316"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  alert_rule_template_guid   = data.azurerm_sentinel_alert_rule_template.test.name
  enabled                    = false
}

data "azurerm_sentinel_alert_rule_template" "test2" {
  display_name               = "(Preview) Anomalous RDP Login Detections"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
}

resource "azurerm_sentinel_alert_rule_machine_learning_behavior_analytics" "test2" {
  name                       = "acctest-SentinelAlertRule-MLBehaviorAnalytics-2-230728030631118316"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  alert_rule_template_guid   = data.azurerm_sentinel_alert_rule_template.test2.name
  enabled                    = false
}
