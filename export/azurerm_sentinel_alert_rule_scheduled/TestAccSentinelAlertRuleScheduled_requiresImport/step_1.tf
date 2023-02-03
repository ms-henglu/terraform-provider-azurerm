


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230203064105590757"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230203064105590757"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name         = "SecurityInsights"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name        = azurerm_log_analytics_workspace.test.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}


resource "azurerm_sentinel_alert_rule_scheduled" "test" {
  name                       = "acctest-SentinelAlertRule-Sche-230203064105590757"
  log_analytics_workspace_id = azurerm_log_analytics_solution.test.workspace_resource_id
  display_name               = "Some Rule"
  severity                   = "High"
  query                      = <<QUERY
AzureActivity |
  where OperationName == "Create or Update Virtual Machine" or OperationName =="Create Deployment" |
  where ActivityStatus == "Succeeded" |
  make-series dcount(ResourceId) default=0 on EventSubmissionTimestamp in range(ago(7d), now(), 1d) by Caller
QUERY
}


resource "azurerm_sentinel_alert_rule_scheduled" "import" {
  name                       = azurerm_sentinel_alert_rule_scheduled.test.name
  log_analytics_workspace_id = azurerm_sentinel_alert_rule_scheduled.test.log_analytics_workspace_id
  display_name               = azurerm_sentinel_alert_rule_scheduled.test.display_name
  severity                   = azurerm_sentinel_alert_rule_scheduled.test.severity
  query                      = azurerm_sentinel_alert_rule_scheduled.test.query
}
