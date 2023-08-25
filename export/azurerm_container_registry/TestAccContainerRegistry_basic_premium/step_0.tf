
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230825024306139442"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230825024306139442"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
