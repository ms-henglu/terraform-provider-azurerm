
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230324051835268595"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230324051835268595"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
