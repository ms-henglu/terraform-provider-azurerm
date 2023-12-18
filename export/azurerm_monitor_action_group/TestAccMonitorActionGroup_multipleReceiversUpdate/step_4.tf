
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072152330274"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-231218072152330274"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
