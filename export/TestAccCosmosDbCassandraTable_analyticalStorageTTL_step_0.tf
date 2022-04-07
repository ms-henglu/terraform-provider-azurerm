

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-220407230828489430"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                       = "acctest-ca-220407230828489430"
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
  name                = "acctest-220407230828489430"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_cassandra_table" "test" {
  name                   = "acctest-CCASST-220407230828489430"
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
