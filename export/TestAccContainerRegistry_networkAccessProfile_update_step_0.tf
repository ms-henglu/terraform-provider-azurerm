
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221019054049970067"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221019054049970067"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
