
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-240112224854978119"
  location = "West Europe"
}
resource "azurerm_application_insights" "test" {
  name                = "acctestAppInsights-240112224854978119"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}
resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240112224854978119"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
resource "azurerm_monitor_scheduled_query_rules_alert" "test" {
  name                    = "acctestsqr-240112224854978119"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  data_source_id          = azurerm_application_insights.test.id
  query                   = <<-QUERY
	let d=datatable(TimeGenerated: datetime, usage_percent: double) [  '2024-01-12T22:48:54Z', 25.4, '2024-01-12T22:48:54Z', 75.4 ];
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
