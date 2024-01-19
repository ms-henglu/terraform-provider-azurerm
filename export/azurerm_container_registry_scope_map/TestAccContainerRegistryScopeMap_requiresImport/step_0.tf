
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-240119024742789853"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr240119024742789853"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testscopemap240119024742789853"
  resource_group_name     = azurerm_resource_group.test.name
  container_registry_name = azurerm_container_registry.test.name
  actions                 = ["repositories/testrepo/content/read"]
}
