
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220610022401065548"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220610022401065548"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
