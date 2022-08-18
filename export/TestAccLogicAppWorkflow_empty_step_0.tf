
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-220818235333546335"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220818235333546335"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
