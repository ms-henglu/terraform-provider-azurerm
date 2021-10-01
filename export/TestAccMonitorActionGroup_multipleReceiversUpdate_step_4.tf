
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021021060539"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211001021021060539"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
