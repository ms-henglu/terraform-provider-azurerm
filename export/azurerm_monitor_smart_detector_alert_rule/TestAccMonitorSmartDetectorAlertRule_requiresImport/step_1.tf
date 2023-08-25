


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-monitor-230825024934317723"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230825024934317723"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230825024934317723"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}


resource "azurerm_monitor_smart_detector_alert_rule" "test" {
  name                = "acctestSDAR-230825024934317723"
  resource_group_name = azurerm_resource_group.test.name
  severity            = "Sev0"
  scope_resource_ids  = [azurerm_application_insights.test.id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"

  action_group {
    ids = [azurerm_monitor_action_group.test.id]
  }
}


resource "azurerm_monitor_smart_detector_alert_rule" "import" {
  name                = azurerm_monitor_smart_detector_alert_rule.test.name
  resource_group_name = azurerm_monitor_smart_detector_alert_rule.test.resource_group_name
  severity            = azurerm_monitor_smart_detector_alert_rule.test.severity
  scope_resource_ids  = azurerm_monitor_smart_detector_alert_rule.test.scope_resource_ids
  frequency           = azurerm_monitor_smart_detector_alert_rule.test.frequency
  detector_type       = azurerm_monitor_smart_detector_alert_rule.test.detector_type

  action_group {
    ids = [azurerm_monitor_action_group.test.id]
  }
}
