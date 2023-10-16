
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-231016033638130671"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr231016033638130671"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = true
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testacccr231016033638130671"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/delete",
    "repositories/hello-world/content/read",
    "repositories/hello-world/content/write",
    "repositories/hello-world/metadata/read",
    "repositories/hello-world/metadata/write",
    "gateway/testacccrc231016033638130671/config/read",
    "gateway/testacccrc231016033638130671/config/write",
    "gateway/testacccrc231016033638130671/message/read",
    "gateway/testacccrc231016033638130671/message/write",
  ]
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testacccrtoken231016033638130671"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.test.id
}

resource "azurerm_container_connected_registry" "test" {
  name                  = "testacccrc231016033638130671"
  container_registry_id = azurerm_container_registry.test.id
  sync_token_id         = azurerm_container_registry_token.test.id
  mode                  = "Registry"
}
