
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221111013305795724"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr221111013305795724"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = true
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testacccr221111013305795724"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/delete",
    "repositories/hello-world/content/read",
    "repositories/hello-world/content/write",
    "repositories/hello-world/metadata/read",
    "repositories/hello-world/metadata/write",
    "gateway/testacccrc221111013305795724/config/read",
    "gateway/testacccrc221111013305795724/config/write",
    "gateway/testacccrc221111013305795724/message/read",
    "gateway/testacccrc221111013305795724/message/write",
    "gateway/testacccrcchild221111013305795724/config/read",
    "gateway/testacccrcchild221111013305795724/config/write",
    "gateway/testacccrcchild221111013305795724/message/read",
    "gateway/testacccrcchild221111013305795724/message/write",
  ]
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testacccrtoken221111013305795724"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.test.id
}

resource "azurerm_container_connected_registry" "test" {
  name                  = "testacccrc221111013305795724"
  container_registry_id = azurerm_container_registry.test.id
  sync_token_id         = azurerm_container_registry_token.test.id
}

resource "azurerm_container_registry_scope_map" "child" {
  name                    = "testacccrchild221111013305795724"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/read",
    "repositories/hello-world/metadata/read",
    "gateway/testacccrcchild221111013305795724/config/read",
    "gateway/testacccrcchild221111013305795724/config/write",
    "gateway/testacccrcchild221111013305795724/message/read",
    "gateway/testacccrcchild221111013305795724/message/write",
  ]
}

resource "azurerm_container_registry_token" "child" {
  name                    = "testacccrtokenchild221111013305795724"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.child.id
}

resource "azurerm_container_connected_registry" "child" {
  name                  = "testacccrcchild221111013305795724"
  container_registry_id = azurerm_container_registry.test.id
  parent_registry_id    = azurerm_container_connected_registry.test.id
  sync_token_id         = azurerm_container_registry_token.child.id
  mode                  = "ReadOnly"
}
