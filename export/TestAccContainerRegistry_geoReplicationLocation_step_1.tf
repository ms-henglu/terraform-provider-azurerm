
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-210924010821468971"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                     = "testacccr210924010821468971"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Premium"
  georeplication_locations = ["eastus2"]
}
