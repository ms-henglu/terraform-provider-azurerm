

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230113181736317750"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230113181736317750"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-230113181736317750"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230113181736317750"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Strong"
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
  name                = "acctest-mongo-230113181736317750"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_mongo_database" "update" {
  name                = "acctest-mongo1-230113181736317750"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_spring_cloud_app_cosmosdb_association" "test" {
  name                         = "acctestscac-230113181736317750"
  spring_cloud_app_id          = azurerm_spring_cloud_app.test.id
  cosmosdb_account_id          = azurerm_cosmosdb_account.test.id
  api_type                     = "mongo"
  cosmosdb_mongo_database_name = azurerm_cosmosdb_mongo_database.update.name
  cosmosdb_access_key          = azurerm_cosmosdb_account.test.primary_key
}
