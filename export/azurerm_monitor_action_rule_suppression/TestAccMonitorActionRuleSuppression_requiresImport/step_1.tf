


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-221021034350361476"
  location = "West Europe"
}


resource "azurerm_monitor_action_rule_suppression" "test" {
  name                = "acctest-moniter-221021034350361476"
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
