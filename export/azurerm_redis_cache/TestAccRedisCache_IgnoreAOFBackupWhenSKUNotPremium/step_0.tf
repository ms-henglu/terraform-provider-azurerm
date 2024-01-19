
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025706905620"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsabaj2q"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_account" "test2" {
  name                     = "acctestsa2baj2q"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-240119025706905620"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false

  redis_configuration {
    aof_backup_enabled = false
    maxmemory_reserved = 125
    maxmemory_delta    = 125
    maxmemory_policy   = "volatile-lru"
  }
}
