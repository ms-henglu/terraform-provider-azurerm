
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-231013043849466458"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestWorkspace-231013043849466458"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-231013043849466458"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}

resource "azurerm_monitor_scheduled_query_rules_alert" "test" {
  name                    = "acctestsqr-231013043849466458"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  data_source_id          = azurerm_log_analytics_workspace.test.id
  query_type              = "Number"
  query                   = <<-QUERY
Heartbeat | summarize AggregatedValue = count() by bin(TimeGenerated, 5m)
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