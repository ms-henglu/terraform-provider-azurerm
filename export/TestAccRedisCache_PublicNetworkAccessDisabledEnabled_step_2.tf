
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825043203803048"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                          = "acctestRedis-210825043203803048"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  capacity                      = 1
  family                        = "C"
  sku_name                      = "Basic"
  minimum_tls_version           = "1.2"
  enable_non_ssl_port           = false
  public_network_access_enabled = false
}
