
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-210830083816408923"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr210830083816408923"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
