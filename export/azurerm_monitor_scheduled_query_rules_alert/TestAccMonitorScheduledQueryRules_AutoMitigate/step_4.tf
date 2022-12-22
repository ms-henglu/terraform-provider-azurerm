
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-221222035024335231"
  location = "West Europe"
}
resource "azurerm_application_insights" "test" {
  name                = "acctestAppInsights-221222035024335231"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}
resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221222035024335231"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
resource "azurerm_monitor_scheduled_query_rules_alert" "test" {
  name                    = "acctestsqr-221222035024335231"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  data_source_id          = azurerm_application_insights.test.id
  query                   = <<-QUERY
	let d=datatable(TimeGenerated: datetime, usage_percent: double) [  '2022-12-22T03:50:24Z', 25.4, '2022-12-22T03:50:24Z', 75.4 ];
	d | summarize AggregatedValue=avg(usage_percent) by bin(TimeGenerated, 1h)
QUERY
  frequency               = 60
  time_window             = 60
  auto_mitigation_enabled = true
  action {
    action_group = [azurerm_monitor_action_group.test.id]
  }
  trigger {
    operator  = "GreaterThan"
    threshold = 5000
  }
}
