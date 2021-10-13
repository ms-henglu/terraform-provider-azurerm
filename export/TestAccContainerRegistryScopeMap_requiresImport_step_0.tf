
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211013071655554068"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211013071655554068"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testscopemap211013071655554068"
  resource_group_name     = azurerm_resource_group.test.name
  container_registry_name = azurerm_container_registry.test.name
  actions                 = ["repositories/testrepo/content/read"]
}
