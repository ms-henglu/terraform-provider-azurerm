

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-apim-220211130135634660"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220211130135634660"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-220211130135634660"
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

resource "azurerm_redis_cache" "test2" {
  name                = "acctestRedis2-220211130135634660"
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


resource "azurerm_api_management_redis_cache" "test" {
  name              = "acctest-Redis-Cache-220211130135634660"
  api_management_id = azurerm_api_management.test.id
  connection_string = azurerm_redis_cache.test2.primary_connection_string
  description       = "Redis cache Update"
  redis_cache_id    = azurerm_redis_cache.test2.id
  cache_location    = "East US 2"
}
