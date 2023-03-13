
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230313020939407326"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230313020939407326"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
