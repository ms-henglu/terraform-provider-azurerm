
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112020937193751"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211112020937193751"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
