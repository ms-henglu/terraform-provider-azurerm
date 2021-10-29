

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-211029020132461416"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-211029020132461416"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name         = "SecurityInsights"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name        = azurerm_log_analytics_workspace.test.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}


data "azurerm_sentinel_alert_rule_template" "test" {
  display_name               = "(Preview) Anomalous SSH Login Detection"
  log_analytics_workspace_id = azurerm_log_analytics_solution.test.workspace_resource_id
}

resource "azurerm_sentinel_alert_rule_machine_learning_behavior_analytics" "test" {
  name                       = "acctest-SentinelAlertRule-MLBehaviorAnalytics-211029020132461416"
  log_analytics_workspace_id = azurerm_log_analytics_solution.test.workspace_resource_id
  alert_rule_template_guid   = data.azurerm_sentinel_alert_rule_template.test.name
}
