
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230922053854820634"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230922053854820634"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
