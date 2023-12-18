
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-231218071521492252"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test1" {
  name                = "acctest-ca-231218071521492252"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  backup {
    type = "Continuous"
  }
}

resource "azurerm_cosmosdb_mongo_database" "test" {
  name                = "acctest-mongodb-231218071521492252"
  resource_group_name = azurerm_cosmosdb_account.test1.resource_group_name
  account_name        = azurerm_cosmosdb_account.test1.name
}

resource "azurerm_cosmosdb_mongo_collection" "test" {
  name                = "acctest-mongodb-coll-231218071521492252"
  resource_group_name = azurerm_cosmosdb_mongo_database.test.resource_group_name
  account_name        = azurerm_cosmosdb_mongo_database.test.account_name
  database_name       = azurerm_cosmosdb_mongo_database.test.name

  index {
    keys   = ["_id"]
    unique = true
  }
}

data "azurerm_cosmosdb_restorable_database_accounts" "test" {
  name     = azurerm_cosmosdb_account.test1.name
  location = azurerm_resource_group.test.location
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca2-231218071521492252"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Session"
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

    database {
      name             = azurerm_cosmosdb_mongo_database.test.name
      collection_names = [azurerm_cosmosdb_mongo_collection.test.name]
    }
  }

  // As "restore_timestamp_in_utc" is retrieved dynamically, so it would cause diff when tf plan. So we have to ignore it here.
  lifecycle {
    ignore_changes = [
      restore.0.restore_timestamp_in_utc
    ]
  }
}
