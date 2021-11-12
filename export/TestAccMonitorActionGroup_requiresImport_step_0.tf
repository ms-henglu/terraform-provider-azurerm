
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112020937191612"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211112020937191612"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
