
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211112020412411397"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211112020412411397"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
