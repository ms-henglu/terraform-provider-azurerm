
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211013071655548105"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211013071655548105"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_enabled       = true
  sku                 = "Premium"

  tags = {
    environment = "production"
  }
  public_network_access_enabled = false
}
