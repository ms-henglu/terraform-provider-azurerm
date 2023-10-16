
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034607869782"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-231016034607869782"
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

  patch_schedule {
    day_of_week        = "Tuesday"
    start_hour_utc     = 8
    maintenance_window = "PT7H"
  }
}
