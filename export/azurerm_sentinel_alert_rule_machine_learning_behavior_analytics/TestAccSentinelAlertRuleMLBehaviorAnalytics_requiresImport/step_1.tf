


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230922061858817557"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230922061858817557"
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
  name                       = "acctest-SentinelAlertRule-MLBehaviorAnalytics-230922061858817557"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  alert_rule_template_guid   = data.azurerm_sentinel_alert_rule_template.test.name

}


resource "azurerm_sentinel_alert_rule_machine_learning_behavior_analytics" "import" {
  name                       = azurerm_sentinel_alert_rule_machine_learning_behavior_analytics.test.name
  log_analytics_workspace_id = azurerm_sentinel_alert_rule_machine_learning_behavior_analytics.test.log_analytics_workspace_id
  alert_rule_template_guid   = azurerm_sentinel_alert_rule_machine_learning_behavior_analytics.test.alert_rule_template_guid
}
