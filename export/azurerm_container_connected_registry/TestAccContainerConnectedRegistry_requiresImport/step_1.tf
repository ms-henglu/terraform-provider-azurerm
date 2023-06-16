


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230616074517892307"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr230616074517892307"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = true
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testacccr230616074517892307"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/delete",
    "repositories/hello-world/content/read",
    "repositories/hello-world/content/write",
    "repositories/hello-world/metadata/read",
    "repositories/hello-world/metadata/write",
    "gateway/testacccrc230616074517892307/config/read",
    "gateway/testacccrc230616074517892307/config/write",
    "gateway/testacccrc230616074517892307/message/read",
    "gateway/testacccrc230616074517892307/message/write",
  ]
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testacccrtoken230616074517892307"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.test.id
}


resource "azurerm_container_connected_registry" "test" {
  name                  = "testacccrc230616074517892307"
  container_registry_id = azurerm_container_registry.test.id
  sync_token_id         = azurerm_container_registry_token.test.id
}


resource "azurerm_container_connected_registry" "import" {
  name                  = azurerm_container_connected_registry.test.name
  container_registry_id = azurerm_container_connected_registry.test.container_registry_id
  sync_token_id         = azurerm_container_connected_registry.test.sync_token_id
}
