
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221221204115026382"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr221221204115026382"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = true
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testacccr221221204115026382"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/delete",
    "repositories/hello-world/content/read",
    "repositories/hello-world/content/write",
    "repositories/hello-world/metadata/read",
    "repositories/hello-world/metadata/write",
    "gateway/testacccrc221221204115026382/config/read",
    "gateway/testacccrc221221204115026382/config/write",
    "gateway/testacccrc221221204115026382/message/read",
    "gateway/testacccrc221221204115026382/message/write",
    "gateway/testacccrcchild221221204115026382/config/read",
    "gateway/testacccrcchild221221204115026382/config/write",
    "gateway/testacccrcchild221221204115026382/message/read",
    "gateway/testacccrcchild221221204115026382/message/write",
  ]
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testacccrtoken221221204115026382"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.test.id
}

resource "azurerm_container_connected_registry" "test" {
  name                  = "testacccrc221221204115026382"
  container_registry_id = azurerm_container_registry.test.id
  sync_token_id         = azurerm_container_registry_token.test.id
}

resource "azurerm_container_registry_scope_map" "child" {
  name                    = "testacccrchild221221204115026382"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/read",
    "repositories/hello-world/metadata/read",
    "gateway/testacccrcchild221221204115026382/config/read",
    "gateway/testacccrcchild221221204115026382/config/write",
    "gateway/testacccrcchild221221204115026382/message/read",
    "gateway/testacccrcchild221221204115026382/message/write",
  ]
}

resource "azurerm_container_registry_token" "child" {
  name                    = "testacccrtokenchild221221204115026382"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.child.id
}

resource "azurerm_container_connected_registry" "child" {
  name                  = "testacccrcchild221221204115026382"
  container_registry_id = azurerm_container_registry.test.id
  parent_registry_id    = azurerm_container_connected_registry.test.id
  sync_token_id         = azurerm_container_registry_token.child.id
  mode                  = "ReadOnly"
}
