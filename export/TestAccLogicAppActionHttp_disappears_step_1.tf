
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210830084140530221"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-210830084140530221"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
