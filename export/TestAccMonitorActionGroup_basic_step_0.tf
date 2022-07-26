
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726015048486465"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220726015048486465"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
