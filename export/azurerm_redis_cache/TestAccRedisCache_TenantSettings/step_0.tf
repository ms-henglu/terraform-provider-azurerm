
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redis-240119025706903361"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-240119025706903361"
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
