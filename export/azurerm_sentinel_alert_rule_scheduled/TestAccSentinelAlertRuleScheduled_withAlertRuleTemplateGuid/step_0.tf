

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230203064105599082"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230203064105599082"
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


resource "azurerm_sentinel_alert_rule_scheduled" "test" {
  name                        = "acctest-SentinelAlertRule-Sche-230203064105599082"
  log_analytics_workspace_id  = azurerm_log_analytics_solution.test.workspace_resource_id
  display_name                = "Some Rule"
  severity                    = "Low"
  alert_rule_template_guid    = "09ec8fa2-b25f-4696-bfae-05a7b85d7b9e"
  alert_rule_template_version = "1.2.1"
  query                       = "Heartbeat"
}
