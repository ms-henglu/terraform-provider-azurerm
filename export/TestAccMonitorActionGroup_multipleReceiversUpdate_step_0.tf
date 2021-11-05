
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105040208641522"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211105040208641522"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
