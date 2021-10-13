
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211013071655544764"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211013071655544764"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
