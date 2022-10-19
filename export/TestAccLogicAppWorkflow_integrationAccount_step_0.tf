
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-221019054532723434"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-221019054532723434"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
