

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-apim-230804025337722299"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230804025337722299"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-230804025337722299"
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
  name                = "acctestRedis2-230804025337722299"
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
  name              = "acctest-Redis-Cache-230804025337722299"
  api_management_id = azurerm_api_management.test.id
  connection_string = azurerm_redis_cache.test.primary_connection_string
  description       = "Redis cache instances"
  redis_cache_id    = azurerm_redis_cache.test.id
  cache_location    = "West US 2"
}
