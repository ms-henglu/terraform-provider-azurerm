


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230915023152956713"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230915023152956713"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_mongo_database" "test" {
  name                = "acctest-230915023152956713"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_mongo_collection" "test" {
  name                = "acctest-230915023152956713"
  resource_group_name = azurerm_cosmosdb_mongo_database.test.resource_group_name
  account_name        = azurerm_cosmosdb_mongo_database.test.account_name
  database_name       = azurerm_cosmosdb_mongo_database.test.name
  shard_key           = "seven"

  index {
    keys   = ["_id"]
    unique = true
  }

  autoscale_settings {
    max_throughput = 4000
  }
}
