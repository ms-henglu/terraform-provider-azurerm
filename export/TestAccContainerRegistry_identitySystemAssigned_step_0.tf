
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220527033959172583"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220527033959172583"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  identity {
    type = "SystemAssigned"
  }
}


