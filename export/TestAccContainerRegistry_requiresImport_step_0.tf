
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211105035707227767"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211105035707227767"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
