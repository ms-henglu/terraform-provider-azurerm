
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623234031793445"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220623234031793445"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
