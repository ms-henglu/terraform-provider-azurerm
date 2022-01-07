
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220107063818120807"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                     = "testacccr220107063818120807"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Premium"
  georeplication_locations = ["westus2"]
}
