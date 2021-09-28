
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075711784419"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-210928075711784419"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
