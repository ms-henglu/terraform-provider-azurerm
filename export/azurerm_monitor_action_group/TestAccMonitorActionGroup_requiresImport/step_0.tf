
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414021752220625"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230414021752220625"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
