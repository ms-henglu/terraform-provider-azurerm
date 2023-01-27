
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230127045643575079"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230127045643575079"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
