

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mongouserdef-230825024317961885"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230825024317961885"
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
  name                = "acctest-mongodb-230825024317961885"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_mongo_role_definition" "test" {
  cosmos_mongo_database_id = azurerm_cosmosdb_mongo_database.test.id
  role_name                = "acctestmongoroledef230825024317961885"
}

resource "azurerm_cosmosdb_mongo_role_definition" "test2" {
  cosmos_mongo_database_id = azurerm_cosmosdb_mongo_database.test.id
  role_name                = "acctestmongoroledef2230825024317961885"
}

resource "azurerm_cosmosdb_mongo_user_definition" "test" {
  cosmos_mongo_database_id = azurerm_cosmosdb_mongo_database.test.id
  username                 = "myUserName-230825024317961885"
  password                 = "myPassword2-230825024317961885"
  inherited_role_names     = [azurerm_cosmosdb_mongo_role_definition.test2.role_name, azurerm_cosmosdb_mongo_role_definition.test.role_name]
}
