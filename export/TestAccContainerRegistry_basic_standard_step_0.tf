
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220326010315914203"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220326010315914203"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
