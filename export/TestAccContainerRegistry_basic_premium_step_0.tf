
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220726001724974839"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220726001724974839"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
