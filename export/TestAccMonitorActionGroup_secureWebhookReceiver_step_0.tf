
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825031904806877"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-210825031904806877"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
