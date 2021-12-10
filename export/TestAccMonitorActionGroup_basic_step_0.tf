
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210035108851608"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211210035108851608"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
