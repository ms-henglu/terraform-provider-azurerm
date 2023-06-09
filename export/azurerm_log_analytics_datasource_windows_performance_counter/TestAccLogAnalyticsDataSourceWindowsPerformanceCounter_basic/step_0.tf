

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-230609091532110255"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230609091532110255"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


resource "azurerm_log_analytics_datasource_windows_performance_counter" "test" {
  name                = "acctestLADS-WPC-230609091532110255"
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
  object_name         = "CPU"
  instance_name       = "*"
  counter_name        = "CPU"
  interval_seconds    = 10
}
