
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230106031252258657"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr230106031252258657"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = true
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testacccr230106031252258657"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/delete",
    "repositories/hello-world/content/read",
    "repositories/hello-world/content/write",
    "repositories/hello-world/metadata/read",
    "repositories/hello-world/metadata/write",
    "gateway/testacccrc230106031252258657/config/read",
    "gateway/testacccrc230106031252258657/config/write",
    "gateway/testacccrc230106031252258657/message/read",
    "gateway/testacccrc230106031252258657/message/write",
    "gateway/testacccrcchild230106031252258657/config/read",
    "gateway/testacccrcchild230106031252258657/config/write",
    "gateway/testacccrcchild230106031252258657/message/read",
    "gateway/testacccrcchild230106031252258657/message/write",
  ]
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testacccrtoken230106031252258657"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.test.id
}

resource "azurerm_container_connected_registry" "test" {
  name                  = "testacccrc230106031252258657"
  container_registry_id = azurerm_container_registry.test.id
  sync_token_id         = azurerm_container_registry_token.test.id
}

resource "azurerm_container_registry_scope_map" "child" {
  name                    = "testacccrchild230106031252258657"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/read",
    "repositories/hello-world/metadata/read",
    "gateway/testacccrcchild230106031252258657/config/read",
    "gateway/testacccrcchild230106031252258657/config/write",
    "gateway/testacccrcchild230106031252258657/message/read",
    "gateway/testacccrcchild230106031252258657/message/write",
  ]
}

resource "azurerm_container_registry_token" "child" {
  name                    = "testacccrtokenchild230106031252258657"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.child.id
}

resource "azurerm_container_connected_registry" "child" {
  name                  = "testacccrcchild230106031252258657"
  container_registry_id = azurerm_container_registry.test.id
  parent_registry_id    = azurerm_container_connected_registry.test.id
  sync_token_id         = azurerm_container_registry_token.child.id
  mode                  = "ReadOnly"
}
