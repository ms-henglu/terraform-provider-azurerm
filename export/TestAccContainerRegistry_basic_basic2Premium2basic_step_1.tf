
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-210928075314401542"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr210928075314401542"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
