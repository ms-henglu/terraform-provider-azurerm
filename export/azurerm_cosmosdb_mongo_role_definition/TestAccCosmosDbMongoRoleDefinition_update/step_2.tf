

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mongoroledef-240119024752529718"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-240119024752529718"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "EnableMongoRoleBasedAccessControl"
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
  name                = "acctest-mongodb-240119024752529718"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_mongo_collection" "test" {
  name                = "acctest-mongocoll-240119024752529718"
  resource_group_name = azurerm_cosmosdb_mongo_database.test.resource_group_name
  account_name        = azurerm_cosmosdb_mongo_database.test.account_name
  database_name       = azurerm_cosmosdb_mongo_database.test.name

  index {
    keys   = ["_id"]
    unique = true
  }
}

resource "azurerm_cosmosdb_mongo_role_definition" "base" {
  cosmos_mongo_database_id = azurerm_cosmosdb_mongo_database.test.id
  role_name                = "acctestbaseroledef240119024752529718"

  depends_on = [azurerm_cosmosdb_mongo_collection.test]
}

resource "azurerm_cosmosdb_mongo_role_definition" "base2" {
  cosmos_mongo_database_id = azurerm_cosmosdb_mongo_database.test.id
  role_name                = "acctestbaseroledef2240119024752529718"

  depends_on = [azurerm_cosmosdb_mongo_collection.test]
}

resource "azurerm_cosmosdb_mongo_database" "test2" {
  name                = "acctest-mongodb2-240119024752529718"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_cosmosdb_mongo_collection" "test2" {
  name                = "acctest-mongocoll2-240119024752529718"
  resource_group_name = azurerm_cosmosdb_mongo_database.test2.resource_group_name
  account_name        = azurerm_cosmosdb_mongo_database.test2.account_name
  database_name       = azurerm_cosmosdb_mongo_database.test2.name

  index {
    keys   = ["_id"]
    unique = true
  }
}

resource "azurerm_cosmosdb_mongo_database" "test3" {
  name                = "acctest-mongodb3-240119024752529718"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_cosmosdb_mongo_collection" "test3" {
  name                = "acctest-mongocoll3-240119024752529718"
  resource_group_name = azurerm_cosmosdb_mongo_database.test3.resource_group_name
  account_name        = azurerm_cosmosdb_mongo_database.test3.account_name
  database_name       = azurerm_cosmosdb_mongo_database.test3.name

  index {
    keys   = ["_id"]
    unique = true
  }
}

resource "azurerm_cosmosdb_mongo_role_definition" "test" {
  cosmos_mongo_database_id = azurerm_cosmosdb_mongo_database.test.id
  role_name                = "acctestmongoroledef240119024752529718"
  inherited_role_names     = [azurerm_cosmosdb_mongo_role_definition.base2.role_name, azurerm_cosmosdb_mongo_role_definition.base.role_name]

  privilege {
    actions = ["insert", "find"]

    resource {
      collection_name = azurerm_cosmosdb_mongo_collection.test2.name
      db_name         = azurerm_cosmosdb_mongo_database.test3.name
    }
  }

  privilege {
    actions = ["find"]

    resource {
      collection_name = azurerm_cosmosdb_mongo_collection.test.name
      db_name         = azurerm_cosmosdb_mongo_database.test2.name
    }
  }

  depends_on = [azurerm_cosmosdb_mongo_collection.test2, azurerm_cosmosdb_mongo_collection.test3]
}
