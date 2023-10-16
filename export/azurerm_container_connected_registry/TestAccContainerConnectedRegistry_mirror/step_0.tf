
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-231016033638136598"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr231016033638136598"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = true
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testacccr231016033638136598"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/read",
    "repositories/hello-world/metadata/read",
    "gateway/testacccrc231016033638136598/config/read",
    "gateway/testacccrc231016033638136598/config/write",
    "gateway/testacccrc231016033638136598/message/read",
    "gateway/testacccrc231016033638136598/message/write",
  ]
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testacccrtoken231016033638136598"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.test.id
}

resource "azurerm_container_connected_registry" "test" {
  name                  = "testacccrc231016033638136598"
  container_registry_id = azurerm_container_registry.test.id
  sync_token_id         = azurerm_container_registry_token.test.id
  mode                  = "Mirror"
}
