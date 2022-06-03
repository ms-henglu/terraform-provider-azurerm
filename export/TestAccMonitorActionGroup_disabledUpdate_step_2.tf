
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603022358851889"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220603022358851889"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
