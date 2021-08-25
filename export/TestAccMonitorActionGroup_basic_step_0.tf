
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825045006668700"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-210825045006668700"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
