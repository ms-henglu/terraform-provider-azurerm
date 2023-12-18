
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-231218072152360376"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestWorkspace-231218072152360376"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_scheduled_query_rules_log" "test" {
  name                = "acctestsqr-231218072152360376"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  data_source_id = azurerm_log_analytics_workspace.test.id

  criteria {
    metric_name = "Average_% Idle Time"
    dimension {
      name     = "InstanceName"
      operator = "Include"
      values   = ["1"]
    }
  }
}
