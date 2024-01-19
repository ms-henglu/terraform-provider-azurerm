
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-240119024742789639"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr240119024742789639"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_enabled       = false
  sku                 = "Premium"

  tags = {
    environment = "production"
  }
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testscopemap240119024742789639"
  description             = "An example scope map"
  resource_group_name     = azurerm_resource_group.test.name
  container_registry_name = azurerm_container_registry.test.name
  actions                 = ["repositories/testrepo/content/read"]
}
