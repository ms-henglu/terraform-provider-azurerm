
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-210825031527826509"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr210825031527826509"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
