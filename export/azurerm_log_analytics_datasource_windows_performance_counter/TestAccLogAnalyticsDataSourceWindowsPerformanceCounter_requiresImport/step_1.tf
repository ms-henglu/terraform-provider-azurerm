


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-230922054358284825"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230922054358284825"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


resource "azurerm_log_analytics_datasource_windows_performance_counter" "test" {
  name                = "acctestLADS-WPC-230922054358284825"
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
  object_name         = "CPU"
  instance_name       = "*"
  counter_name        = "CPU"
  interval_seconds    = 10
}


resource "azurerm_log_analytics_datasource_windows_performance_counter" "import" {
  name                = azurerm_log_analytics_datasource_windows_performance_counter.test.name
  resource_group_name = azurerm_log_analytics_datasource_windows_performance_counter.test.resource_group_name
  workspace_name      = azurerm_log_analytics_datasource_windows_performance_counter.test.workspace_name
  object_name         = azurerm_log_analytics_datasource_windows_performance_counter.test.object_name
  instance_name       = azurerm_log_analytics_datasource_windows_performance_counter.test.instance_name
  counter_name        = azurerm_log_analytics_datasource_windows_performance_counter.test.counter_name
  interval_seconds    = azurerm_log_analytics_datasource_windows_performance_counter.test.interval_seconds
}
