
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064313988217"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230929064313988217"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_smart_detection_rule" "test" {
  name                    = "Slow page load time"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}

resource "azurerm_application_insights_smart_detection_rule" "test2" {
  name                    = "Slow server response time"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}

resource "azurerm_application_insights_smart_detection_rule" "test3" {
  name                    = "Long dependency duration"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}

resource "azurerm_application_insights_smart_detection_rule" "test4" {
  name                    = "Degradation in server response time"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}

resource "azurerm_application_insights_smart_detection_rule" "test5" {
  name                    = "Degradation in dependency duration"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}

resource "azurerm_application_insights_smart_detection_rule" "test6" {
  name                    = "Degradation in trace severity ratio"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}

resource "azurerm_application_insights_smart_detection_rule" "test7" {
  name                    = "Abnormal rise in exception volume"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}

resource "azurerm_application_insights_smart_detection_rule" "test8" {
  name                    = "Potential memory leak detected"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}

resource "azurerm_application_insights_smart_detection_rule" "test9" {
  name                    = "Potential security issue detected"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}

resource "azurerm_application_insights_smart_detection_rule" "test10" {
  name                    = "Abnormal rise in daily data volume"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}
