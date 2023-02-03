
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230203063101375731"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230203063101375731"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
