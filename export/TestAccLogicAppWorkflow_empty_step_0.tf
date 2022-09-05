
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-220905050104384247"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220905050104384247"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
