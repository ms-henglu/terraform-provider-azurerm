
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-230825024934314641"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestAppInsights-230825024934314641"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230825024934314641"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}

resource "azurerm_monitor_scheduled_query_rules_alert" "test" {
  name                = "acctestsqr-230825024934314641"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  data_source_id = azurerm_application_insights.test.id
  query          = <<-QUERY
	let d=datatable(TimeGenerated: datetime, usage_percent: double) [  '2023-08-25T02:49:34Z', 25.4, '2023-08-25T02:49:34Z', 75.4 ];
	d | summarize AggregatedValue=avg(usage_percent) by bin(TimeGenerated, 1h)
QUERY


  enabled     = false
  description = "test description"

  frequency   = 30
  time_window = 30

  action {
    action_group = [azurerm_monitor_action_group.test.id]
  }

  trigger {
    operator  = "GreaterThan"
    threshold = 1000
  }
}
