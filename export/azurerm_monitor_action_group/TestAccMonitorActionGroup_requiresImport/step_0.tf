
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061531660741"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230922061531660741"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
