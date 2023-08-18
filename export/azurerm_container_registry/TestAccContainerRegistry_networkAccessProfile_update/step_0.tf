
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230818023753475852"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230818023753475852"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
