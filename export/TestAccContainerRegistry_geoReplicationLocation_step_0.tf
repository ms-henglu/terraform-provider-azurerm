
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211008044217867603"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                     = "testacccr211008044217867603"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Premium"
  georeplication_locations = ["westus2"]
}
