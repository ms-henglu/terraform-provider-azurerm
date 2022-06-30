
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220630223533990464"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220630223533990464"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
