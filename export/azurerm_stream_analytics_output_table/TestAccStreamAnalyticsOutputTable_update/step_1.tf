

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204923219139"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacccobhv"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst221221204923219139"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-221221204923219139"
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


resource "azurerm_storage_account" "updated" {
  name                     = "acctestaccucobhv"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "updated" {
  name                 = "accteststu221221204923219139"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_stream_analytics_output_table" "test" {
  name                      = "acctestoutput-221221204923219139"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  storage_account_name      = azurerm_storage_account.updated.name
  storage_account_key       = azurerm_storage_account.updated.primary_access_key
  table                     = "updated"
  partition_key             = "partitionkeyupdated"
  row_key                   = "rowkeyupdated"
  batch_size                = 50
}
