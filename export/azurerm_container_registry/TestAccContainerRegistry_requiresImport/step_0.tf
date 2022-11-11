
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221111020216862709"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221111020216862709"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
