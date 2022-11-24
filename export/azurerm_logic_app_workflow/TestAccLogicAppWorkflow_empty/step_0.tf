
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-221124181904711038"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-221124181904711038"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
