
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230324052320856942"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230324052320856942"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
