
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211022001810169076"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211022001810169076"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
