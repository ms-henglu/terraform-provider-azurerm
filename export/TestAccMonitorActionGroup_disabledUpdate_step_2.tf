
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015901029182"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211029015901029182"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
