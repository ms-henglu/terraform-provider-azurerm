
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024830105987"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211210024830105987"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
