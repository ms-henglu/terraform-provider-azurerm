
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224854920185"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240112224854920185"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
