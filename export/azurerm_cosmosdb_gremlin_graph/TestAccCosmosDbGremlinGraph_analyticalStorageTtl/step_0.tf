
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-231218071521508529"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                       = "acctest-ca-231218071521508529"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  offer_type                 = "Standard"
  kind                       = "GlobalDocumentDB"
  analytical_storage_enabled = true

  consistency_policy {
    consistency_level = "Strong"
  }

  capabilities {
    name = "EnableGremlin"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_gremlin_database" "test" {
  name                = "acctest-db-231218071521508529"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_cosmosdb_gremlin_graph" "test" {
  name                   = "acctest-CGRPC-231218071521508529"
  resource_group_name    = azurerm_cosmosdb_account.test.resource_group_name
  account_name           = azurerm_cosmosdb_account.test.name
  database_name          = azurerm_cosmosdb_gremlin_database.test.name
  partition_key_path     = "/test"
  throughput             = 400
  analytical_storage_ttl = -1
}
