


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-220610022847342609"
  location = "West Europe"
}


resource "azurerm_monitor_action_rule_suppression" "test" {
  name                = "acctest-moniter-220610022847342609"
  resource_group_name = azurerm_resource_group.test.name

  suppression {
    recurrence_type = "Always"
  }
}


resource "azurerm_monitor_action_rule_suppression" "import" {
  name                = azurerm_monitor_action_rule_suppression.test.name
  resource_group_name = azurerm_monitor_action_rule_suppression.test.resource_group_name

  suppression {
    recurrence_type = azurerm_monitor_action_rule_suppression.test.suppression.0.recurrence_type
  }
}
