
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107034212709843"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220107034212709843"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
