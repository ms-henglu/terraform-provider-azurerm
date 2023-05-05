
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505050850312439"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230505050850312439"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
