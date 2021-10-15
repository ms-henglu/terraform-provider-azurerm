
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014702708583"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acct1r4jl"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-211015014702708583"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 3
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false

  redis_configuration {
    notify_keyspace_events = "KAE"
  }
}
