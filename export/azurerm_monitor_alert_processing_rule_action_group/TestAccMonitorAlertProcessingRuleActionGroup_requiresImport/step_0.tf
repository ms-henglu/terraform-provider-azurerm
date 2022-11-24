

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-maprag-221124182015270226"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221124182015270226"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctest-ag"
}


resource "azurerm_monitor_alert_processing_rule_action_group" "test" {
  name                 = "acctest-moniter-221124182015270226"
  resource_group_name  = azurerm_resource_group.test.name
  add_action_group_ids = [azurerm_monitor_action_group.test.id]
  scopes               = [azurerm_resource_group.test.id]
}
