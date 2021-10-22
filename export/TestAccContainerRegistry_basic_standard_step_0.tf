
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211022001810165693"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211022001810165693"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
