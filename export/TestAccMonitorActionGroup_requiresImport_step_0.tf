
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072134553921"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211013072134553921"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
