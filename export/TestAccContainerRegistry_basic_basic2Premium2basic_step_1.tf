
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-210825040629314584"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr210825040629314584"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
