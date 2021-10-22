
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022002222063949"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211022002222063949"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
