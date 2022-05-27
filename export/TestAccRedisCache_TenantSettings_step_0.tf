
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redis-220527034603018441"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-220527034603018441"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 3
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false
  tenant_settings = {
    config = "config"
  }
}
