
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810143847058705"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230810143847058705"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
