
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211126031436078710"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211126031436078710"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
