
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-220204093204082187"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220204093204082187"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
