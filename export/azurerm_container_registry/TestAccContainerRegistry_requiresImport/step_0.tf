
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230613071610072022"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230613071610072022"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
