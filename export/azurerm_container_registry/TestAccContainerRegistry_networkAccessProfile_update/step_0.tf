
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230609091047831590"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230609091047831590"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
