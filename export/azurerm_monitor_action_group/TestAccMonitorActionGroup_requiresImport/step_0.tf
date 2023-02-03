
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203063756501892"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230203063756501892"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
