
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124182015272414"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221124182015272414"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
