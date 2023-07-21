
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230721014802792048"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230721014802792048"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
