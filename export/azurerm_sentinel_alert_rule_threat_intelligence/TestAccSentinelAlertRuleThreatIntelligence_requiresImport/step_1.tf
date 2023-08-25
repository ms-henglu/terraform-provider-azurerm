


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230825025244752114"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230825025244752114"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}

data "azurerm_sentinel_alert_rule_template" "test" {
  display_name               = "(Preview) Microsoft Defender Threat Intelligence Analytics"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
}


resource "azurerm_sentinel_alert_rule_threat_intelligence" "test" {
  name                       = "acctest-SentinelAlertRule-ThreatIntelligence-230825025244752114"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  alert_rule_template_guid   = data.azurerm_sentinel_alert_rule_template.test.name
}


resource "azurerm_sentinel_alert_rule_threat_intelligence" "import" {
  name                       = azurerm_sentinel_alert_rule_threat_intelligence.test.name
  log_analytics_workspace_id = azurerm_sentinel_alert_rule_threat_intelligence.test.log_analytics_workspace_id
  alert_rule_template_guid   = azurerm_sentinel_alert_rule_threat_intelligence.test.alert_rule_template_guid
}
