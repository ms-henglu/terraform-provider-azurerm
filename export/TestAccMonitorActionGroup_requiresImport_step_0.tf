
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520040936617971"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220520040936617971"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
