
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-231016033638143031"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr231016033638143031"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
