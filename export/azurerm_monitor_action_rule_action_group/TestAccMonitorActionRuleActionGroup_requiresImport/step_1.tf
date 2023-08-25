


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-230825024934280054"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230825024934280054"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}


resource "azurerm_monitor_action_rule_action_group" "test" {
  name                = "acctest-moniter-230825024934280054"
  resource_group_name = azurerm_resource_group.test.name
  action_group_id     = azurerm_monitor_action_group.test.id
}


resource "azurerm_monitor_action_rule_action_group" "import" {
  name                = azurerm_monitor_action_rule_action_group.test.name
  resource_group_name = azurerm_monitor_action_rule_action_group.test.resource_group_name
  action_group_id     = azurerm_monitor_action_rule_action_group.test.action_group_id
}
