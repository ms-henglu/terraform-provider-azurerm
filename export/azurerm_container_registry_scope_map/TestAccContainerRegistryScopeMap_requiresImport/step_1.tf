

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-240112034116500130"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr240112034116500130"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testscopemap240112034116500130"
  resource_group_name     = azurerm_resource_group.test.name
  container_registry_name = azurerm_container_registry.test.name
  actions                 = ["repositories/testrepo/content/read"]
}


resource "azurerm_container_registry_scope_map" "import" {
  name                    = azurerm_container_registry_scope_map.test.name
  resource_group_name     = azurerm_container_registry_scope_map.test.resource_group_name
  container_registry_name = azurerm_container_registry_scope_map.test.container_registry_name
  actions                 = azurerm_container_registry_scope_map.test.actions
}
