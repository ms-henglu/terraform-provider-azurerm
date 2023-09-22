
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-230922054524087712"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestAppInsights-230922054524087712"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230922054524087712"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}

resource "azurerm_monitor_scheduled_query_rules_alert" "test" {
  name                = "acctestsqr-230922054524087712"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  description         = "test alerting action"
  enabled             = true

  data_source_id = azurerm_application_insights.test.id
  query          = "let d=datatable(TimeGenerated: datetime, usage_percent: double) [  '2023-09-22T05:45:24Z', 25.4, '2023-09-22T05:45:24Z', 75.4 ]; d | summarize AggregatedValue=avg(usage_percent) by bin(TimeGenerated, 1h)"

  frequency   = 60
  time_window = 60

  severity   = 3
  throttling = 5

  action {
    action_group           = [azurerm_monitor_action_group.test.id]
    email_subject          = "Custom alert email subject"
    custom_webhook_payload = "{}"
  }

  trigger {
    operator  = "GreaterThan"
    threshold = 5000
    metric_trigger {
      operator            = "GreaterThan"
      threshold           = 1
      metric_trigger_type = "Total"
      metric_column       = "TimeGenerated"
    }
  }

  tags = {
    Env = "test"
  }
}
