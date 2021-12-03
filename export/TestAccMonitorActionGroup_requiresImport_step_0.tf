
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203161641632717"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211203161641632717"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
