

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-210928055302368645"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                       = "acctest-ca-210928055302368645"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  offer_type                 = "Standard"
  kind                       = "GlobalDocumentDB"
  analytical_storage_enabled = true

  consistency_policy {
    consistency_level = "Strong"
  }

  capabilities {
    name = "EnableCassandra"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_cassandra_keyspace" "test" {
  name                = "acctest-210928055302368645"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_cassandra_table" "test" {
  name                   = "acctest-CCASST-210928055302368645"
  cassandra_keyspace_id  = azurerm_cosmosdb_cassandra_keyspace.test.id
  analytical_storage_ttl = 0

  schema {
    column {
      name = "test1"
      type = "ascii"
    }

    column {
      name = "test2"
      type = "int"
    }

    partition_key {
      name = "test1"
    }
  }
}
