
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220326010859242692"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220326010859242692"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
