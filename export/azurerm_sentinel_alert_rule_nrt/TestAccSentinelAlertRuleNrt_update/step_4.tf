

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230428050509849521"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230428050509849521"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_alert_rule_nrt" "test" {
  name                       = "acctest-SentinelAlertRule-NRT-230428050509849521"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "Updated Complete Rule"
  severity                   = "High"
  query                      = "Heartbeat"
  custom_details = {
    OperatingSystemName = "OSName"
    OperatingSystemType = "OSType"
  }

}
