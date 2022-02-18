
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220218071027181050"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220218071027181050"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
