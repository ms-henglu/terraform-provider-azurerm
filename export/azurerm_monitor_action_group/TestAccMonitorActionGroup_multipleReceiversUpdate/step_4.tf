
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030817921476"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230602030817921476"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
