
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220124124857761869"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220124124857761869"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
