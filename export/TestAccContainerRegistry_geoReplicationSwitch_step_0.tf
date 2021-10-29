
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211029015401154023"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                     = "testacccr211029015401154023"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Premium"
  georeplication_locations = ["westus2","eastus2"]
}
