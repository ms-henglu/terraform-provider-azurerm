
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230505050128762185"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr230505050128762185"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = true
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testacccr230505050128762185"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/delete",
    "repositories/hello-world/content/read",
    "repositories/hello-world/content/write",
    "repositories/hello-world/metadata/read",
    "repositories/hello-world/metadata/write",
    "gateway/testacccrc230505050128762185/config/read",
    "gateway/testacccrc230505050128762185/config/write",
    "gateway/testacccrc230505050128762185/message/read",
    "gateway/testacccrc230505050128762185/message/write",
    "gateway/testacccrcchild230505050128762185/config/read",
    "gateway/testacccrcchild230505050128762185/config/write",
    "gateway/testacccrcchild230505050128762185/message/read",
    "gateway/testacccrcchild230505050128762185/message/write",
  ]
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testacccrtoken230505050128762185"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.test.id
}

resource "azurerm_container_connected_registry" "test" {
  name                  = "testacccrc230505050128762185"
  container_registry_id = azurerm_container_registry.test.id
  sync_token_id         = azurerm_container_registry_token.test.id
}

resource "azurerm_container_registry_scope_map" "child" {
  name                    = "testacccrchild230505050128762185"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/read",
    "repositories/hello-world/metadata/read",
    "gateway/testacccrcchild230505050128762185/config/read",
    "gateway/testacccrcchild230505050128762185/config/write",
    "gateway/testacccrcchild230505050128762185/message/read",
    "gateway/testacccrcchild230505050128762185/message/write",
  ]
}

resource "azurerm_container_registry_token" "child" {
  name                    = "testacccrtokenchild230505050128762185"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.child.id
}

resource "azurerm_container_connected_registry" "child" {
  name                  = "testacccrcchild230505050128762185"
  container_registry_id = azurerm_container_registry.test.id
  parent_registry_id    = azurerm_container_connected_registry.test.id
  sync_token_id         = azurerm_container_registry_token.child.id
  mode                  = "ReadOnly"
}
