
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-230810143847085086"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestWorkspace-230810143847085086"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_scheduled_query_rules_log" "test" {
  name                = "acctestsqr-230810143847085086"
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
