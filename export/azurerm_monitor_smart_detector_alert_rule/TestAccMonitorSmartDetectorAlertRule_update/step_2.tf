

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-monitor-230825024934314156"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230825024934314156"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230825024934314156"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}


resource "azurerm_monitor_smart_detector_alert_rule" "test" {
  name                = "acctestSDAR-230825024934314156"
  resource_group_name = azurerm_resource_group.test.name
  severity            = "Sev0"
  scope_resource_ids  = [azurerm_application_insights.test.id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"

  description = "acctest"
  enabled     = false

  action_group {
    ids             = [azurerm_monitor_action_group.test.id]
    email_subject   = "acctest email subject"
    webhook_payload = <<BODY
{
    "msg": "Acctest payload body"
}
BODY
  }

  throttling_duration = "PT20M"

  tags = {
    Env = "Test"
  }
}
