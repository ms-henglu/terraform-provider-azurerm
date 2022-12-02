
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221202035358377327"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221202035358377327"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_enabled       = false
  sku                 = "Basic"

  tags = {
    environment = "production"
  }
}
