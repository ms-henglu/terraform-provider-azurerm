
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-240311031710516465"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr240311031710516465"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
