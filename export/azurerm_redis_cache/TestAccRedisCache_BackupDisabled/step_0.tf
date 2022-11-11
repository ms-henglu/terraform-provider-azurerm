
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014126573113"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-221111014126573113"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 3
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false

  redis_configuration {
    rdb_backup_enabled = false
  }
}
