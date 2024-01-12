


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-maprag-240112034757503387"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240112034757503387"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctest-ag"
}


resource "azurerm_monitor_alert_processing_rule_action_group" "test" {
  name                 = "acctest-moniter-240112034757503387"
  resource_group_name  = azurerm_resource_group.test.name
  add_action_group_ids = [azurerm_monitor_action_group.test.id]
  scopes               = [azurerm_resource_group.test.id]
}


resource "azurerm_monitor_alert_processing_rule_action_group" "import" {
  name                 = azurerm_monitor_alert_processing_rule_action_group.test.name
  resource_group_name  = azurerm_monitor_alert_processing_rule_action_group.test.resource_group_name
  add_action_group_ids = azurerm_monitor_alert_processing_rule_action_group.test.add_action_group_ids
  scopes               = azurerm_monitor_alert_processing_rule_action_group.test.scopes
}
