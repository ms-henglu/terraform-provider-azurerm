
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028165253744386"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221028165253744386"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
