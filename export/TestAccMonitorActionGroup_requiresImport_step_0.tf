
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217075547464584"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211217075547464584"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
