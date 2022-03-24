
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324163548269336"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220324163548269336"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
