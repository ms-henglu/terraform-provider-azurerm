
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034757492040"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240112034757492040"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
