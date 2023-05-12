
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512004421722722"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230512004421722722"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
