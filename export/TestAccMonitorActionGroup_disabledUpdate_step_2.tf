
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044703656652"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211008044703656652"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
