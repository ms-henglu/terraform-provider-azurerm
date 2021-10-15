
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211015014444952298"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211015014444952298"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_enabled       = false
  sku                 = "Premium"

  tags = {
    environment = "production"
  }
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testscopemap211015014444952298"
  description             = "An example scope map"
  resource_group_name     = azurerm_resource_group.test.name
  container_registry_name = azurerm_container_registry.test.name
  actions                 = ["repositories/testrepo/content/read"]
}
