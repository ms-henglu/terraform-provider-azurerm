
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025706903334"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-240119025706903334"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = true
  shard_count         = 3

  redis_configuration {
    maxmemory_reserved              = 642
    maxfragmentationmemory_reserved = 642
    maxmemory_delta                 = 642
    maxmemory_policy                = "allkeys-lru"
  }
}
