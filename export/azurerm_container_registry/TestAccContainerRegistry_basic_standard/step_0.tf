
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230929064631505779"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230929064631505779"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
