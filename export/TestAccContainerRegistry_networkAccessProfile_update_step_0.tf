
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211217075043330157"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211217075043330157"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
