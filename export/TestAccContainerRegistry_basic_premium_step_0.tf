
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211029015401159304"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211029015401159304"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
