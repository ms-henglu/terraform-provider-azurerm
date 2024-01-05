
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-240105063536303280"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr240105063536303280"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
