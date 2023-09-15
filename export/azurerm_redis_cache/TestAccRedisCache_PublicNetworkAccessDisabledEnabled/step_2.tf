
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024056556455"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                          = "acctestRedis-230915024056556455"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  capacity                      = 1
  family                        = "C"
  sku_name                      = "Basic"
  minimum_tls_version           = "1.2"
  enable_non_ssl_port           = false
  public_network_access_enabled = false
}
