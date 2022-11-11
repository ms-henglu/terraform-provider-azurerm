
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020844372988"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221111020844372988"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
