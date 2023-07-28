

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230728032026544552"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr230728032026544552"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = true
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testacccr230728032026544552"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/delete",
    "repositories/hello-world/content/read",
    "repositories/hello-world/content/write",
    "repositories/hello-world/metadata/read",
    "repositories/hello-world/metadata/write",
    "gateway/testacccrc230728032026544552/config/read",
    "gateway/testacccrc230728032026544552/config/write",
    "gateway/testacccrc230728032026544552/message/read",
    "gateway/testacccrc230728032026544552/message/write",
  ]
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testacccrtoken230728032026544552"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.test.id
}


resource "azurerm_container_registry_scope_map" "client" {
  name                    = "testacccrclient230728032026544552"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  actions = [
    "repositories/hello-world/content/delete",
    "repositories/hello-world/content/read",
    "repositories/hello-world/content/write",
    "repositories/hello-world/metadata/read",
    "repositories/hello-world/metadata/write",
  ]
}

resource "azurerm_container_registry_token" "client" {
  name                    = "testacccrtokenclient230728032026544552"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.client.id
}

resource "azurerm_container_connected_registry" "test" {
  name                  = "testacccrc230728032026544552"
  container_registry_id = azurerm_container_registry.test.id
  sync_token_id         = azurerm_container_registry_token.test.id
  notification {
    name   = "hello-world"
    tag    = "latest"
    action = "*"
  }
  log_level         = "Debug"
  audit_log_enabled = true
  client_token_ids  = [azurerm_container_registry_token.client.id]

  # This is necessary to make the Terraform apply order works correctly.
  # Without CBD: azurerm_container_registry_token.client (destroy) -> azurerm_container_connected_registry.test (update)
  # 			 (the 1st step wil fail as the token is under used by the connected registry)
  # With CBD   : azurerm_container_connected_registry.test (update) -> azurerm_container_registry_token.client (destroy) 
  lifecycle {
    create_before_destroy = true
  }
}
