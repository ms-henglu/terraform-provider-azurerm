
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001054117394642"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-211001054117394642"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 2
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = true
  shard_count         = 3

  redis_configuration {
    maxmemory_reserved              = 2
    maxfragmentationmemory_reserved = 2
    maxmemory_delta                 = 2
    maxmemory_policy                = "allkeys-lru"
  }
}
