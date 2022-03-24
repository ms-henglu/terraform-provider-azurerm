
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-220324163548268666"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220324163548268666"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
