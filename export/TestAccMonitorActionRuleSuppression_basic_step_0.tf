

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-220826003031535060"
  location = "West Europe"
}


resource "azurerm_monitor_action_rule_suppression" "test" {
  name                = "acctest-moniter-220826003031535060"
  resource_group_name = azurerm_resource_group.test.name

  suppression {
    recurrence_type = "Always"
  }
}
