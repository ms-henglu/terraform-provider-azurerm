

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204837754992"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctestacce0a3b"
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
  name                = "test-containere0a3b"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  partition_key_path  = "/definition"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "testspringcloudservice-e0a3b"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "testspringcloud-e0a3b"
  resource_group_name = azurerm_resource_group.test.name
  service_name        = azurerm_spring_cloud_service.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_spring_cloud_java_deployment" "test" {
  name                = "deploy-e0a3b"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
}


resource "azurerm_cosmosdb_sql_database" "update" {
  name                = "cosmos-sql-db-update"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "update" {
  name                = "test-containerupdatee0a3b"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.update.name
  partition_key_path  = "/definitionupdate"
}

resource "azurerm_spring_cloud_service" "update" {
  name                = "updatespringcloud-e0a3b"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_spring_cloud_app" "update" {
  name                = "testspringcloudupdate-e0a3b"
  resource_group_name = azurerm_resource_group.test.name
  service_name        = azurerm_spring_cloud_service.update.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_spring_cloud_java_deployment" "update" {
  name                = "deploy-e0a3b"
  spring_cloud_app_id = azurerm_spring_cloud_app.update.id
}

resource "azurerm_spring_cloud_connection" "test" {
  name               = "acctestserviceconnector221221204837754992"
  spring_cloud_id    = azurerm_spring_cloud_java_deployment.update.id
  target_resource_id = azurerm_cosmosdb_sql_database.update.id
  authentication {
    type = "systemAssignedIdentity"
  }
}
