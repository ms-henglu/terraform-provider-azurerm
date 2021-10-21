
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021235243024127"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211021235243024127"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
