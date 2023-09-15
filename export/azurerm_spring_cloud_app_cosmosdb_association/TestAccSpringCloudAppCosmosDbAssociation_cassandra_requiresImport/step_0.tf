

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230915024230032453"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230915024230032453"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-230915024230032453"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230915024230032453"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

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
  name                = "acctest-ck-230915024230032453"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_spring_cloud_app_cosmosdb_association" "test" {
  name                             = "acctestscac-230915024230032453"
  spring_cloud_app_id              = azurerm_spring_cloud_app.test.id
  cosmosdb_account_id              = azurerm_cosmosdb_account.test.id
  api_type                         = "cassandra"
  cosmosdb_cassandra_keyspace_name = azurerm_cosmosdb_cassandra_keyspace.test.name
  cosmosdb_access_key              = azurerm_cosmosdb_account.test.primary_key
}
