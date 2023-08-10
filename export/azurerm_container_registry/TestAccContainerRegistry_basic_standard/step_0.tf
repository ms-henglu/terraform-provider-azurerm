
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230810143212725365"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230810143212725365"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
