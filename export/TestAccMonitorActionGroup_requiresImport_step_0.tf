
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225034720399880"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220225034720399880"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
