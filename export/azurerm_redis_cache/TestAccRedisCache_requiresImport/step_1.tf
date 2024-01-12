

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112225132404933"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-240112225132404933"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}


resource "azurerm_redis_cache" "import" {
  name                = azurerm_redis_cache.test.name
  location            = azurerm_redis_cache.test.location
  resource_group_name = azurerm_redis_cache.test.resource_group_name
  capacity            = azurerm_redis_cache.test.capacity
  family              = azurerm_redis_cache.test.family
  sku_name            = azurerm_redis_cache.test.sku_name
  enable_non_ssl_port = azurerm_redis_cache.test.enable_non_ssl_port

  redis_configuration {
  }
}
