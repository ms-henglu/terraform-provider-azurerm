
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025203405168"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaeykzy"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_account" "test2" {
  name                     = "acctestsa2eykzy"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-230825025203405168"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false

  redis_configuration {
    aof_backup_enabled              = true
    aof_storage_connection_string_0 = azurerm_storage_account.test.primary_connection_string
    aof_storage_connection_string_1 = azurerm_storage_account.test2.primary_connection_string
  }
}
