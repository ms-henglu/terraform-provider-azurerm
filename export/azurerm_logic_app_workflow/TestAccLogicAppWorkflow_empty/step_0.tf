
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240311032431501158"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-240311032431501158"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
