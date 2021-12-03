
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211203013607863966"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211203013607863966"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
