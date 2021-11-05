
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211105025807843706"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211105025807843706"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
