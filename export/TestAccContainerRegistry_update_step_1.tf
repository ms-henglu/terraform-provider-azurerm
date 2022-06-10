
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220610022401061561"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220610022401061561"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_enabled       = true
  sku                 = "Premium"

  tags = {
    environment = "production"
  }
  public_network_access_enabled = false
}
