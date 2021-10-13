

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-211013072134550774"
  location = "West Europe"
}


resource "azurerm_monitor_action_rule_suppression" "test" {
  name                = "acctest-moniter-211013072134550774"
  resource_group_name = azurerm_resource_group.test.name

  suppression {
    recurrence_type = "Always"
  }
}
