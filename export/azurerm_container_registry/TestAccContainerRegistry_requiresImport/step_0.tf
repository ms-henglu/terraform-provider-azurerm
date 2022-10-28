
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221028171920519854"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221028171920519854"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
