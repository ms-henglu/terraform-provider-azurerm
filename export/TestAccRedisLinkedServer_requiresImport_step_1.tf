

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "pri" {
  name     = "acctestRG-redis-220121044906500876"
  location = "West Europe"
}

resource "azurerm_redis_cache" "pri" {
  name                = "acctestRedispri220121044906500876"
  location            = azurerm_resource_group.pri.location
  resource_group_name = azurerm_resource_group.pri.name
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false

  redis_configuration {
    maxmemory_reserved = 2
    maxmemory_delta    = 2
    maxmemory_policy   = "allkeys-lru"
  }
}

resource "azurerm_resource_group" "sec" {
  name     = "acctestRG-220121044906500876"
  location = "West US 2"
}

resource "azurerm_redis_cache" "sec" {
  name                = "acctestRedissec220121044906500876"
  location            = azurerm_resource_group.sec.location
  resource_group_name = azurerm_resource_group.sec.name
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false

  redis_configuration {
    maxmemory_reserved = 2
    maxmemory_delta    = 2
    maxmemory_policy   = "allkeys-lru"
  }
}

resource "azurerm_redis_linked_server" "test" {
  target_redis_cache_name     = azurerm_redis_cache.pri.name
  resource_group_name         = azurerm_redis_cache.pri.resource_group_name
  linked_redis_cache_id       = azurerm_redis_cache.sec.id
  linked_redis_cache_location = azurerm_redis_cache.sec.location
  server_role                 = "Secondary"
}


resource "azurerm_redis_linked_server" "import" {
  target_redis_cache_name     = azurerm_redis_linked_server.test.target_redis_cache_name
  resource_group_name         = azurerm_redis_linked_server.test.resource_group_name
  linked_redis_cache_id       = azurerm_redis_linked_server.test.linked_redis_cache_id
  linked_redis_cache_location = azurerm_redis_linked_server.test.linked_redis_cache_location
  server_role                 = azurerm_redis_linked_server.test.server_role
}
