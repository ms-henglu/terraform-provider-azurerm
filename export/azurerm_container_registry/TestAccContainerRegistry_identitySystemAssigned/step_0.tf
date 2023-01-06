
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230106031252252210"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230106031252252210"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  identity {
    type = "SystemAssigned"
  }
}


