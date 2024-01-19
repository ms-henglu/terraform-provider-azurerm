
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025423965863"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240119025423965863"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
  enabled             = false
}
