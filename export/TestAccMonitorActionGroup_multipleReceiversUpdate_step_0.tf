
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203161641631246"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211203161641631246"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
