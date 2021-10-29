

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029020308037685"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccjmzad"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst211029020308037685"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-211029020308037685"
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
  name                      = "acctestoutput-211029020308037685"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  storage_account_name      = azurerm_storage_account.test.name
  storage_account_key       = azurerm_storage_account.test.primary_access_key
  table                     = "foobar"
  partition_key             = "foo"
  row_key                   = "bar"
}
