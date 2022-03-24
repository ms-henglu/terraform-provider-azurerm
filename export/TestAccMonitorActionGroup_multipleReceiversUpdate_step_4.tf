
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324160600828210"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220324160600828210"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
