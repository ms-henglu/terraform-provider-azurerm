
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031722184071"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230106031722184071"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
