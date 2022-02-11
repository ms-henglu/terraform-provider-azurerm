
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220211130918500473"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220211130918500473"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
