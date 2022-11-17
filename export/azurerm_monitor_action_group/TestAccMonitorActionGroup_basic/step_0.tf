
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231213995391"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221117231213995391"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
