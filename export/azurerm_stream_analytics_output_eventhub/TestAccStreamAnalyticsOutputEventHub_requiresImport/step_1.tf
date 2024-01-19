


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025936852662"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctestehn-240119025936852662"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteh-240119025936852662"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-240119025936852662"
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


resource "azurerm_stream_analytics_output_eventhub" "test" {
  name                      = "acctestinput-240119025936852662"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  eventhub_name             = azurerm_eventhub.test.name
  servicebus_namespace      = azurerm_eventhub_namespace.test.name
  shared_access_policy_key  = azurerm_eventhub_namespace.test.default_primary_key
  shared_access_policy_name = "RootManageSharedAccessKey"

  serialization {
    type     = "Json"
    encoding = "UTF8"
    format   = "LineSeparated"
  }
}


resource "azurerm_stream_analytics_output_eventhub" "import" {
  name                      = azurerm_stream_analytics_output_eventhub.test.name
  stream_analytics_job_name = azurerm_stream_analytics_output_eventhub.test.stream_analytics_job_name
  resource_group_name       = azurerm_stream_analytics_output_eventhub.test.resource_group_name
  eventhub_name             = azurerm_stream_analytics_output_eventhub.test.eventhub_name
  servicebus_namespace      = azurerm_stream_analytics_output_eventhub.test.servicebus_namespace
  shared_access_policy_key  = azurerm_stream_analytics_output_eventhub.test.shared_access_policy_key
  shared_access_policy_name = azurerm_stream_analytics_output_eventhub.test.shared_access_policy_name

  serialization {
    type     = azurerm_stream_analytics_output_eventhub.test.serialization.0.type
    encoding = azurerm_stream_analytics_output_eventhub.test.serialization.0.encoding
    format   = azurerm_stream_analytics_output_eventhub.test.serialization.0.format
  }
}
