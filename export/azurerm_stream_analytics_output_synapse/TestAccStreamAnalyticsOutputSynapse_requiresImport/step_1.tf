


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421023026435613"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccy6rye"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctestdlfsy6rye"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestswy6rye"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-y6rye"
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


resource "azurerm_stream_analytics_output_synapse" "test" {
  name                      = "acctestoutput-230421023026435613"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name

  server   = azurerm_synapse_workspace.test.connectivity_endpoints["sqlOnDemand"]
  user     = azurerm_synapse_workspace.test.sql_administrator_login
  password = azurerm_synapse_workspace.test.sql_administrator_login_password
  database = "master"
  table    = "AccTestTable"
}


resource "azurerm_stream_analytics_output_synapse" "import" {
  name                      = azurerm_stream_analytics_output_synapse.test.name
  stream_analytics_job_name = azurerm_stream_analytics_output_synapse.test.stream_analytics_job_name
  resource_group_name       = azurerm_stream_analytics_output_synapse.test.resource_group_name

  server   = azurerm_synapse_workspace.test.connectivity_endpoints["sqlOnDemand"]
  user     = azurerm_synapse_workspace.test.sql_administrator_login
  password = azurerm_synapse_workspace.test.sql_administrator_login_password
  database = "master"
  table    = "AccTestTable"
}
