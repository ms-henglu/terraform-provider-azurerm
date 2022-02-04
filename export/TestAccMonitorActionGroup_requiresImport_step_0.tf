
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204093303803667"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220204093303803667"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
