
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220627122516732065"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                     = "testacccr220627122516732065"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Premium"
  georeplication_locations = ["eastus2"]
}
