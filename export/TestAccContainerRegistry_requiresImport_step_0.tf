
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220211043405132295"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220211043405132295"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
