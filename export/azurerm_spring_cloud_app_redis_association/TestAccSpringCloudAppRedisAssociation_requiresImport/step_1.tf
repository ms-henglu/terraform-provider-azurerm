


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-231016034754034995"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-231016034754034995"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-231016034754034995"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestredis-231016034754034995"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = true
}


resource "azurerm_spring_cloud_app_redis_association" "test" {
  name                = "acctestscarb-231016034754034995"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
  redis_cache_id      = azurerm_redis_cache.test.id
  redis_access_key    = azurerm_redis_cache.test.primary_access_key
}


resource "azurerm_spring_cloud_app_redis_association" "import" {
  name                = azurerm_spring_cloud_app_redis_association.test.name
  spring_cloud_app_id = azurerm_spring_cloud_app_redis_association.test.spring_cloud_app_id
  redis_cache_id      = azurerm_spring_cloud_app_redis_association.test.redis_cache_id
  redis_access_key    = azurerm_spring_cloud_app_redis_association.test.redis_access_key
}
