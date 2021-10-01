
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001224301491220"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211001224301491220"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
