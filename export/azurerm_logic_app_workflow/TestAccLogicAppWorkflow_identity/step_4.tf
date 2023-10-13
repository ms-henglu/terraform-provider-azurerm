
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-231013043728172947"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-231013043728172947"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
