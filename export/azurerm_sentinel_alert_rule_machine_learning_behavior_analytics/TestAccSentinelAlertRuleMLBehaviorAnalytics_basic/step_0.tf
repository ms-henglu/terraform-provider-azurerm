

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230630033910947696"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230630033910947696"
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
  name                       = "acctest-SentinelAlertRule-MLBehaviorAnalytics-230630033910947696"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  alert_rule_template_guid   = data.azurerm_sentinel_alert_rule_template.test.name

}
