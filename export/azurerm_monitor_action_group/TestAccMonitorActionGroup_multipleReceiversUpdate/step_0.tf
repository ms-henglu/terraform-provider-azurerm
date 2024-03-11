
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032620058300"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240311032620058300"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
