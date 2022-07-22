
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220722051750880616"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220722051750880616"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
