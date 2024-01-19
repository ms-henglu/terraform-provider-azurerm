
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022727828030"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                          = "acctestRedis-240119022727828030"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  capacity                      = 3
  family                        = "P"
  sku_name                      = "Premium"
  enable_non_ssl_port           = false
  public_network_access_enabled = false

  redis_configuration {
    active_directory_authentication_enabled = true
  }
}
