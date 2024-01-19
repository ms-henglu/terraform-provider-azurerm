


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-240119025749562522"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                               = "acctestLAW-240119025749562522"
  location                           = azurerm_resource_group.test.location
  resource_group_name                = azurerm_resource_group.test.name
  sku                                = "CapacityReservation"
  reservation_capacity_in_gb_per_day = 100
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_alert_rule_ms_security_incident" "test" {
  name                       = "acctest-SentinelAlertRule-MSI-240119025749562522"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  product_filter             = "Microsoft Cloud App Security"
  display_name               = "some rule"
  severity_filter            = ["High"]
}


resource "azurerm_sentinel_alert_rule_ms_security_incident" "import" {
  name                       = azurerm_sentinel_alert_rule_ms_security_incident.test.name
  log_analytics_workspace_id = azurerm_sentinel_alert_rule_ms_security_incident.test.log_analytics_workspace_id
  product_filter             = azurerm_sentinel_alert_rule_ms_security_incident.test.product_filter
  display_name               = azurerm_sentinel_alert_rule_ms_security_incident.test.display_name
  severity_filter            = azurerm_sentinel_alert_rule_ms_security_incident.test.severity_filter
}
