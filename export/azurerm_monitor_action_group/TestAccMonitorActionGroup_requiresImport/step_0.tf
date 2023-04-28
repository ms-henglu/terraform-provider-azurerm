
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428050149195391"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230428050149195391"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
