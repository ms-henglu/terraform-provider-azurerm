

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024316091777"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctestacclf0iu"
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
  name                = "test-containerWest Europe"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  partition_key_path  = "/definition"
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-230915024316091777"
  resource_group_name                      = azurerm_resource_group.test.name
  location                                 = azurerm_resource_group.test.location
  compatibility_level                      = "1.0"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 3

  transformation_query = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY

}


resource "azurerm_cosmosdb_sql_database" "updated" {
  name                = "updated-cosmos-sql-db"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "updated" {
  name                = "updated-containerlf0iu"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.updated.name
  partition_key_path  = "/definition"
}

resource "azurerm_stream_analytics_output_cosmosdb" "test" {
  name                     = "acctestoutput-230915024316091777"
  stream_analytics_job_id  = azurerm_stream_analytics_job.test.id
  cosmosdb_account_key     = azurerm_cosmosdb_account.test.primary_key
  cosmosdb_sql_database_id = azurerm_cosmosdb_sql_database.updated.id
  container_name           = azurerm_cosmosdb_sql_container.updated.name
}
