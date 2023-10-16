

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-231016033649280621"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-231016033649280621"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  analytical_storage_enabled = true

  consistency_policy {
    consistency_level = "Eventual"
  }

  capabilities {
    name = "EnableMongo"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_mongo_database" "test" {
  name                = "acctest-231016033649280621"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_cosmosdb_mongo_collection" "test" {
  name                = "acctest-231016033649280621"
  resource_group_name = azurerm_cosmosdb_mongo_database.test.resource_group_name
  account_name        = azurerm_cosmosdb_mongo_database.test.account_name
  database_name       = azurerm_cosmosdb_mongo_database.test.name

  index {
    keys   = ["_id"]
    unique = true
  }

  analytical_storage_ttl = 600
}
