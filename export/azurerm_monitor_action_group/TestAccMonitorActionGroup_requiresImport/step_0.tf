
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085515325911"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230526085515325911"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
