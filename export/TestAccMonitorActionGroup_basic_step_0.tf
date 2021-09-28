
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055705397033"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-210928055705397033"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
