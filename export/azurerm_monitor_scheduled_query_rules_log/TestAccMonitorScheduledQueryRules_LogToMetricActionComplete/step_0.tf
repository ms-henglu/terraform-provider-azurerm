
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-231016034326124726"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestAppInsights-231016034326124726"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestWorkspace-231016034326124726"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-231016034326124726"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}

resource "azurerm_monitor_scheduled_query_rules_log" "test" {
  name                = "acctestsqr-231016034326124726"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  description         = "test log to metric action"
  enabled             = true

  data_source_id          = azurerm_log_analytics_workspace.test.id
  authorized_resource_ids = [azurerm_application_insights.test.id, azurerm_log_analytics_workspace.test.id]

  criteria {
    metric_name = "Average_% Idle Time"
    dimension {
      name     = "Computer"
      operator = "Include"
      values   = ["*"]
    }
  }
  tags = {
    ENV = "test"
  }
}

resource "azurerm_monitor_metric_alert" "test" {
  name                = "acctestmal-231016034326124726"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_log_analytics_workspace.test.id]
  description         = "Action will be triggered when Average % Idle Time is less than 10."

  criteria {
    metric_namespace = "Microsoft.OperationalInsights/workspaces"
    metric_name      = azurerm_monitor_scheduled_query_rules_log.test.criteria[0].metric_name
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.test.id
  }
}
