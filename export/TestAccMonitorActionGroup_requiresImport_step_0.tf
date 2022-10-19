
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019054644027852"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221019054644027852"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
