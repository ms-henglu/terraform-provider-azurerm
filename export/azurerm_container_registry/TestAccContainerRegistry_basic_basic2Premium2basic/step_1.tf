
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230915023140714082"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230915023140714082"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
