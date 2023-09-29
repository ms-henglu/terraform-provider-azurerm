
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065550484779"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-230929065550484779"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false

  redis_configuration {
    maxmemory_reserved = 642
    maxmemory_delta    = 642
    maxmemory_policy   = "allkeys-lru"
  }
}

resource "azurerm_redis_firewall_rule" "test" {
  name                = "fwrule230929065550484779"
  redis_cache_name    = azurerm_redis_cache.test.name
  resource_group_name = azurerm_resource_group.test.name
  start_ip            = "1.2.3.4"
  end_ip              = "2.3.4.5"
}
