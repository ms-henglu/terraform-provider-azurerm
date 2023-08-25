


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-maprs-230825024934297859"
  location = "West Europe"
}


resource "azurerm_monitor_alert_processing_rule_suppression" "test" {
  name                = "acctest-moniter-230825024934297859"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_resource_group.test.id]
}


resource "azurerm_monitor_alert_processing_rule_suppression" "import" {
  name                = azurerm_monitor_alert_processing_rule_suppression.test.name
  resource_group_name = azurerm_monitor_alert_processing_rule_suppression.test.resource_group_name
  scopes              = azurerm_monitor_alert_processing_rule_suppression.test.scopes
}
