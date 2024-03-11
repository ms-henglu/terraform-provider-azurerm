


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311033322860226"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsamllg6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "example"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-240311033322860226"
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


resource "azurerm_stream_analytics_output_blob" "test" {
  name                      = "acctestinput-240311033322860226"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  storage_account_name      = azurerm_storage_account.test.name
  storage_account_key       = azurerm_storage_account.test.primary_access_key
  storage_container_name    = azurerm_storage_container.test.name
  path_pattern              = "some-pattern"
  date_format               = "yyyy-MM-dd"
  time_format               = "HH"

  serialization {
    type     = "Json"
    encoding = "UTF8"
    format   = "LineSeparated"
  }
}


resource "azurerm_stream_analytics_output_blob" "import" {
  name                      = azurerm_stream_analytics_output_blob.test.name
  stream_analytics_job_name = azurerm_stream_analytics_output_blob.test.stream_analytics_job_name
  resource_group_name       = azurerm_stream_analytics_output_blob.test.resource_group_name
  storage_account_name      = azurerm_stream_analytics_output_blob.test.storage_account_name
  storage_account_key       = azurerm_stream_analytics_output_blob.test.storage_account_key
  storage_container_name    = azurerm_stream_analytics_output_blob.test.storage_container_name
  path_pattern              = azurerm_stream_analytics_output_blob.test.path_pattern
  date_format               = azurerm_stream_analytics_output_blob.test.date_format
  time_format               = azurerm_stream_analytics_output_blob.test.time_format
  dynamic "serialization" {
    for_each = azurerm_stream_analytics_output_blob.test.serialization
    content {
      encoding = lookup(serialization.value, "encoding", null)
      format   = lookup(serialization.value, "format", null)
      type     = serialization.value.type
    }
  }
}
