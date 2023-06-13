
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613072255487611"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230613072255487611"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
