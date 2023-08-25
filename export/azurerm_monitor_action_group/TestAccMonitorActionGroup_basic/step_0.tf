
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024934285116"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230825024934285116"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
