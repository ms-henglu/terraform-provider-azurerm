
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230113180906222109"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230113180906222109"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
