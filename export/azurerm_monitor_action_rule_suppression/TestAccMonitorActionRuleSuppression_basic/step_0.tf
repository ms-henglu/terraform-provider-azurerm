

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-221111013922338120"
  location = "West Europe"
}


resource "azurerm_monitor_action_rule_suppression" "test" {
  name                = "acctest-moniter-221111013922338120"
  resource_group_name = azurerm_resource_group.test.name

  suppression {
    recurrence_type = "Always"
  }
}
