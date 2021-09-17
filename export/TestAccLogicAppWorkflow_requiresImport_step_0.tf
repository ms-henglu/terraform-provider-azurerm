
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-210917031849676926"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-210917031849676926"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
