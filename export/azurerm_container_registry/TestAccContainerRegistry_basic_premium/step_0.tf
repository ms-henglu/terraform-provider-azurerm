
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221021033929395347"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221021033929395347"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
