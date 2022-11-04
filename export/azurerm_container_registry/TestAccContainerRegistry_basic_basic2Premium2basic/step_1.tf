
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221104005240092212"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221104005240092212"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
