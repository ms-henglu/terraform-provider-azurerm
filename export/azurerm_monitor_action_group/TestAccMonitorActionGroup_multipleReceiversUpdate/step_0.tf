
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022447653278"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240119022447653278"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
