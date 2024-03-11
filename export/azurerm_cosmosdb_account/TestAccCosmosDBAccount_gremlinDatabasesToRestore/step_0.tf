
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-240311031725335214"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test1" {
  name                = "acctest-ca-240311031725335214"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableGremlin"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  backup {
    type = "Continuous"
  }
}

resource "azurerm_cosmosdb_gremlin_database" "test" {
  name                = "acctest-gremlindb-240311031725335214"
  resource_group_name = azurerm_cosmosdb_account.test1.resource_group_name
  account_name        = azurerm_cosmosdb_account.test1.name
}

resource "azurerm_cosmosdb_gremlin_graph" "test" {
  name                = "acctest-CGRPC-240311031725335214"
  resource_group_name = azurerm_cosmosdb_account.test1.resource_group_name
  account_name        = azurerm_cosmosdb_account.test1.name
  database_name       = azurerm_cosmosdb_gremlin_database.test.name
  partition_key_path  = "/test"
  throughput          = 400
}

resource "azurerm_cosmosdb_gremlin_graph" "test2" {
  name                = "acctest-CGRPC2-240311031725335214"
  resource_group_name = azurerm_cosmosdb_account.test1.resource_group_name
  account_name        = azurerm_cosmosdb_account.test1.name
  database_name       = azurerm_cosmosdb_gremlin_database.test.name
  partition_key_path  = "/test2"
  throughput          = 500

  depends_on = [azurerm_cosmosdb_gremlin_graph.test]
}

data "azurerm_cosmosdb_restorable_database_accounts" "test" {
  name     = azurerm_cosmosdb_account.test1.name
  location = azurerm_resource_group.test.location

  depends_on = [azurerm_cosmosdb_gremlin_graph.test2]
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca2-240311031725335214"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableGremlin"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  backup {
    type = "Continuous"
  }

  create_mode = "Restore"

  restore {
    source_cosmosdb_account_id = data.azurerm_cosmosdb_restorable_database_accounts.test.accounts[0].id
    restore_timestamp_in_utc   = timeadd(timestamp(), "-1s")

    gremlin_database {
      name        = azurerm_cosmosdb_gremlin_database.test.name
      graph_names = [azurerm_cosmosdb_gremlin_graph.test.name, azurerm_cosmosdb_gremlin_graph.test2.name]
    }
  }

  // As "restore_timestamp_in_utc" is retrieved dynamically, so it would cause diff when tf plan. So we have to ignore it here.
  lifecycle {
    ignore_changes = [
      restore.0.restore_timestamp_in_utc
    ]
  }
}
