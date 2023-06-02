
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230602030327809536"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230602030327809536"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
