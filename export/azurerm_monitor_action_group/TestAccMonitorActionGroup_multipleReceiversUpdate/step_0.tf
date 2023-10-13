
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043849444225"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-231013043849444225"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
