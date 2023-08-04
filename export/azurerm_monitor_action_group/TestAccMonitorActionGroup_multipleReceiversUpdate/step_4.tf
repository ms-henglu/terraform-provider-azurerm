
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030334098930"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230804030334098930"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
