

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119051319053640"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-211119051319053640"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
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

resource "azurerm_redis_firewall_rule" "test" {
  name                = "fwrule211119051319053640"
  redis_cache_name    = azurerm_redis_cache.test.name
  resource_group_name = azurerm_resource_group.test.name
  start_ip            = "1.2.3.4"
  end_ip              = "2.3.4.5"
}


resource "azurerm_redis_firewall_rule" "import" {
  name                = azurerm_redis_firewall_rule.test.name
  redis_cache_name    = azurerm_redis_firewall_rule.test.redis_cache_name
  resource_group_name = azurerm_redis_firewall_rule.test.resource_group_name
  start_ip            = azurerm_redis_firewall_rule.test.start_ip
  end_ip              = azurerm_redis_firewall_rule.test.end_ip
}
