
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085515323587"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230526085515323587"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
