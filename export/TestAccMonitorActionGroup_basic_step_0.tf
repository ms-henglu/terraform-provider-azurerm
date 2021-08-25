
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825041051202692"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-210825041051202692"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
