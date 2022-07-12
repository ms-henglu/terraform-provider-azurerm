
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220712042108812272"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220712042108812272"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
