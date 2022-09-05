
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220905050210865595"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220905050210865595"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
