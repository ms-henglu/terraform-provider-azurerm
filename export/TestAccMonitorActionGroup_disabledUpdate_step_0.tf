
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003031536875"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220826003031536875"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
  enabled             = false
}
