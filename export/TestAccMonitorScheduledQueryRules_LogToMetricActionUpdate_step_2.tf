
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-220726015048491753"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestWorkspace-220726015048491753"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_scheduled_query_rules_log" "test" {
  name                = "acctestsqr-220726015048491753"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  description         = "test log to metric action"
  enabled             = true

  data_source_id = azurerm_log_analytics_workspace.test.id

  criteria {
    metric_name = "Average_% Idle Time"
    dimension {
      name     = "InstanceName"
      operator = "Include"
      values   = ["2"]
    }
  }
}
