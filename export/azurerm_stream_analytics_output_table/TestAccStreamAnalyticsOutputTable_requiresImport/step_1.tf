


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020042003080182"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccasxu1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst231020042003080182"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-231020042003080182"
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


resource "azurerm_stream_analytics_output_table" "test" {
  name                      = "acctestoutput-231020042003080182"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  storage_account_name      = azurerm_storage_account.test.name
  storage_account_key       = azurerm_storage_account.test.primary_access_key
  table                     = "foobar"
  partition_key             = "foo"
  row_key                   = "bar"
  batch_size                = 100
}


resource "azurerm_stream_analytics_output_table" "import" {
  name                      = azurerm_stream_analytics_output_table.test.name
  stream_analytics_job_name = azurerm_stream_analytics_output_table.test.stream_analytics_job_name
  resource_group_name       = azurerm_stream_analytics_output_table.test.resource_group_name
  storage_account_name      = azurerm_stream_analytics_output_table.test.storage_account_name
  storage_account_key       = azurerm_stream_analytics_output_table.test.storage_account_key
  table                     = azurerm_stream_analytics_output_table.test.table
  partition_key             = azurerm_stream_analytics_output_table.test.partition_key
  row_key                   = azurerm_stream_analytics_output_table.test.row_key
  batch_size                = azurerm_stream_analytics_output_table.test.batch_size
}
