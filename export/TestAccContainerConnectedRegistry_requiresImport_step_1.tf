


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220819165039255763"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr220819165039255763"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = true
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testacccr220819165039255763"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/delete",
    "repositories/hello-world/content/read",
    "repositories/hello-world/content/write",
    "repositories/hello-world/metadata/read",
    "repositories/hello-world/metadata/write",
    "gateway/testacccrc220819165039255763/config/read",
    "gateway/testacccrc220819165039255763/config/write",
    "gateway/testacccrc220819165039255763/message/read",
    "gateway/testacccrc220819165039255763/message/write",
  ]
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testacccrtoken220819165039255763"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.test.id
}


resource "azurerm_container_connected_registry" "test" {
  name                  = "testacccrc220819165039255763"
  container_registry_id = azurerm_container_registry.test.id
  sync_token_id         = azurerm_container_registry_token.test.id
}


resource "azurerm_container_connected_registry" "import" {
  name                  = azurerm_container_connected_registry.test.name
  container_registry_id = azurerm_container_connected_registry.test.container_registry_id
  sync_token_id         = azurerm_container_connected_registry.test.sync_token_id
}
