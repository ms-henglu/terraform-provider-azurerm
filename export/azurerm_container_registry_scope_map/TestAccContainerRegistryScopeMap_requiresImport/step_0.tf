
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221117230656481619"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221117230656481619"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testscopemap221117230656481619"
  resource_group_name     = azurerm_resource_group.test.name
  container_registry_name = azurerm_container_registry.test.name
  actions                 = ["repositories/testrepo/content/read"]
}
