
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-210826023215576225"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr210826023215576225"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
