

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324052752630098"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctestaccnav9n"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "test" {
  name                = "cosmos-sql-db"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "test" {
  name                = "test-containernav9n"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  partition_key_path  = "/definition"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "testspringcloudservice-nav9n"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "testspringcloud-nav9n"
  resource_group_name = azurerm_resource_group.test.name
  service_name        = azurerm_spring_cloud_service.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_spring_cloud_java_deployment" "test" {
  name                = "deploy-nav9n"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
}


resource "azurerm_spring_cloud_connection" "test" {
  name               = "acctestserviceconnector230324052752630098"
  spring_cloud_id    = azurerm_spring_cloud_java_deployment.test.id
  target_resource_id = azurerm_cosmosdb_sql_database.test.id
  client_type        = "java"
  authentication {
    type = "systemAssignedIdentity"
  }
}
