
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220627124005871926"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220627124005871926"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
