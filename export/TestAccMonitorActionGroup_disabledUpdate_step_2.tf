
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019054644025874"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221019054644025874"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
