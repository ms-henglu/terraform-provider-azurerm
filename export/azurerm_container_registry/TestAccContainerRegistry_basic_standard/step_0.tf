
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221221204115020657"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221221204115020657"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
