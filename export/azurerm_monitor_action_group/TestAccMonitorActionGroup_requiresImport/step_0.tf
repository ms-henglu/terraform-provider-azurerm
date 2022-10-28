
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172502835187"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221028172502835187"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
