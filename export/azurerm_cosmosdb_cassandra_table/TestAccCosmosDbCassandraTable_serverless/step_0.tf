


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230825024317952550"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230825024317952550"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  capabilities {name = "EnableCassandra"}
capabilities {name = "EnableServerless"}


  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_cassandra_keyspace" "test" {
  name                = "acctest-230825024317952550"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_cassandra_table" "test" {
  name                  = "acctest-CCASST-230825024317952550"
  cassandra_keyspace_id = azurerm_cosmosdb_cassandra_keyspace.test.id

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
