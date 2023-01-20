
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230120051728545857"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230120051728545857"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}
