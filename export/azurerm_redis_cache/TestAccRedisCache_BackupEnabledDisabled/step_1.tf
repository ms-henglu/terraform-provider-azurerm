
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024056556082"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaob0y9"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_account" "test2" {
  name                     = "acctestsa2ob0y9"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_account" "test3" {
  name                     = "acctestsa3ob0y9"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-230915024056556082"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 3
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false

  redis_configuration {
    rdb_backup_enabled              = false
    aof_backup_enabled              = true
    aof_storage_connection_string_0 = azurerm_storage_account.test2.primary_connection_string
    aof_storage_connection_string_1 = azurerm_storage_account.test3.primary_connection_string
  }
}
