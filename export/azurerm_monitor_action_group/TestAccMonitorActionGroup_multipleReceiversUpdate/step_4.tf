
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041503948535"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-231020041503948535"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
