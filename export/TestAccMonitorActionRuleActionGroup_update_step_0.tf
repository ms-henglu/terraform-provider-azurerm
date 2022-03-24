

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-220324163655947161"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220324163655947161"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}


resource "azurerm_monitor_action_rule_action_group" "test" {
  name                = "acctest-moniter-220324163655947161"
  resource_group_name = azurerm_resource_group.test.name
  action_group_id     = azurerm_monitor_action_group.test.id
}
