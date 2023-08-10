
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810143847052425"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230810143847052425"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
