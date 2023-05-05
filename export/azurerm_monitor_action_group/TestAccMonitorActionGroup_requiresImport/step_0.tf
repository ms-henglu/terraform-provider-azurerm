
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505050850318246"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230505050850318246"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
