

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-230414021752236571"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230414021752236571"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}


resource "azurerm_monitor_action_rule_action_group" "test" {
  name                = "acctest-moniter-230414021752236571"
  resource_group_name = azurerm_resource_group.test.name
  action_group_id     = azurerm_monitor_action_group.test.id
}
