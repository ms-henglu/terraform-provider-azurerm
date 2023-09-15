

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230915024139506579"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                               = "acctestLAW-230915024139506579"
  location                           = azurerm_resource_group.test.location
  resource_group_name                = azurerm_resource_group.test.name
  sku                                = "CapacityReservation"
  reservation_capacity_in_gb_per_day = 100
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_alert_rule_ms_security_incident" "test" {
  name                        = "acctest-SentinelAlertRule-MSI-230915024139506579"
  log_analytics_workspace_id  = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  product_filter              = "Microsoft Cloud App Security"
  display_name                = "some rule"
  severity_filter             = ["High"]
  display_name_filter         = ["alert1"]
  display_name_exclude_filter = ["alert4"]
}
