
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redis-230721015901340329"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                 = "acctestRedis-230721015901340329"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  capacity             = 3
  family               = "P"
  sku_name             = "Premium"
  enable_non_ssl_port  = false
  replicas_per_primary = 3
}
