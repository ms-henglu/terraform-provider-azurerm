

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-monitor-230804030334124082"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230804030334124082"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230804030334124082"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}


resource "azurerm_monitor_smart_detector_alert_rule" "test" {
  name                = "acctestSDAR-230804030334124082"
  resource_group_name = azurerm_resource_group.test.name
  severity            = "Sev0"
  scope_resource_ids  = [azurerm_application_insights.test.id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"

  action_group {
    ids = [azurerm_monitor_action_group.test.id]
  }
}
