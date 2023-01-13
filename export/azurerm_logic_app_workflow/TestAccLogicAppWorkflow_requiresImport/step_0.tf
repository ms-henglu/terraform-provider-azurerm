
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230113181321210671"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230113181321210671"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
