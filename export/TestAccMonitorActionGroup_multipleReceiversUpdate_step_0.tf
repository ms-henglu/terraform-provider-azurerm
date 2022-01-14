
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114014515155339"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220114014515155339"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
