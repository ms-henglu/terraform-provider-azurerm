
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211013071655542047"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                     = "testacccr211013071655542047"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Premium"
  georeplication_locations = []
}
