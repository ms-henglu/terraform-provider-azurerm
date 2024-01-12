

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-240112035116018942"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240112035116018942"
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

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_alert_rule_scheduled" "test" {
  name                        = "acctest-SentinelAlertRule-Sche-240112035116018942"
  log_analytics_workspace_id  = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name                = "Some Rule"
  severity                    = "Low"
  alert_rule_template_guid    = "09ec8fa2-b25f-4696-bfae-05a7b85d7b9e"
  alert_rule_template_version = "1.2.1"
  query                       = "Heartbeat"

}
