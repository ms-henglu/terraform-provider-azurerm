
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906022515121039"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-210906022515121039"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
