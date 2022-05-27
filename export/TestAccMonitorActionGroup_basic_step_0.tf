
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527024513757985"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220527024513757985"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
