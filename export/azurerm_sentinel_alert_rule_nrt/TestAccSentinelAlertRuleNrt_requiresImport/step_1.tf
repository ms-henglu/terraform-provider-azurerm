


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230825025244757900"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230825025244757900"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_alert_rule_nrt" "test" {
  name                       = "acctest-SentinelAlertRule-NRT-230825025244757900"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "Some Rule"
  severity                   = "High"
  query                      = <<QUERY
AzureActivity |
  where OperationName == "Create or Update Virtual Machine" or OperationName =="Create Deployment" |
  where ActivityStatus == "Succeeded" |
  make-series dcount(ResourceId) default=0 on EventSubmissionTimestamp in range(ago(7d), now(), 1d) by Caller
QUERY
}


resource "azurerm_sentinel_alert_rule_nrt" "import" {
  name                       = azurerm_sentinel_alert_rule_nrt.test.name
  log_analytics_workspace_id = azurerm_sentinel_alert_rule_nrt.test.log_analytics_workspace_id
  display_name               = azurerm_sentinel_alert_rule_nrt.test.display_name
  severity                   = azurerm_sentinel_alert_rule_nrt.test.severity
  query                      = azurerm_sentinel_alert_rule_nrt.test.query
}
