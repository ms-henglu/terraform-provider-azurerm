
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311042734938108"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220311042734938108"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
