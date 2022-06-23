
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223654077266"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220623223654077266"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
