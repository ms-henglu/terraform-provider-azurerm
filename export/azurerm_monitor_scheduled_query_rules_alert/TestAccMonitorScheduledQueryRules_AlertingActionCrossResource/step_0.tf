
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-230922061531689116"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestAppInsights-230922061531689116"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  application_type    = "web"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestWorkspace-230922061531689116"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230922061531689116"
  resource_group_name = "${azurerm_resource_group.test.name}"
  short_name          = "acctestag"
}

resource "azurerm_monitor_scheduled_query_rules_alert" "test" {
  name                = "acctestsqr-230922061531689116"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  description         = "test alerting action cross-resource"
  enabled             = true

  authorized_resource_ids = ["${azurerm_application_insights.test.id}", "${azurerm_log_analytics_workspace.test.id}"]
  data_source_id          = "${azurerm_application_insights.test.id}"
  query = format(<<-QUERY
	let a=workspace('%s').Perf
		| where Computer == 'dependency' and TimeGenerated > ago(1h)
		| where ObjectName == 'Processor' and CounterName == '%% Processor Time'
		| summarize cpu=avg(CounterValue) by bin(TimeGenerated, 1m)
		| extend ts=tostring(TimeGenerated); let b=requests
		| where resultCode == '200' and timestamp > ago(1h)
		| summarize reqs=count() by bin(timestamp, 1m)
		| extend ts = tostring(timestamp); a
		| join b on $left.ts == $right.ts
		| where cpu > 50 and reqs > 5
QUERY
  , azurerm_log_analytics_workspace.test.id)

  frequency   = 60
  time_window = 60

  severity = 3
  action {
    action_group  = ["${azurerm_monitor_action_group.test.id}"]
    email_subject = "Custom alert email subject"
  }

  trigger {
    operator  = "GreaterThan"
    threshold = 5000
  }
}
