
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623233921974741"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220623233921974741"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
