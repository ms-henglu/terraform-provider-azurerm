
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072134553755"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211013072134553755"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
