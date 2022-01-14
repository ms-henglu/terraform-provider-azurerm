
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220114063948095301"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220114063948095301"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_enabled       = true
  sku                 = "Premium"

  tags = {
    environment = "production"
  }
  public_network_access_enabled = false
}
