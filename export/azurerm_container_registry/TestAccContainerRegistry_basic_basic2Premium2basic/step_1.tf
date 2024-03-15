
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-240315122643907038"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr240315122643907038"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
