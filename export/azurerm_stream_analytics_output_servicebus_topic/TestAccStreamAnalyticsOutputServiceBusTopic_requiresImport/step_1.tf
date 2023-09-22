


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922055013500415"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-230922055013500415"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctest-230922055013500415"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = true
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-230922055013500415"
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


resource "azurerm_stream_analytics_output_servicebus_topic" "test" {
  name                      = "acctestinput-230922055013500415"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  topic_name                = azurerm_servicebus_topic.test.name
  servicebus_namespace      = azurerm_servicebus_namespace.test.name
  shared_access_policy_key  = azurerm_servicebus_namespace.test.default_primary_key
  shared_access_policy_name = "RootManageSharedAccessKey"

  serialization {
    type     = "Json"
    encoding = "UTF8"
    format   = "LineSeparated"
  }
}


resource "azurerm_stream_analytics_output_servicebus_topic" "import" {
  name                      = azurerm_stream_analytics_output_servicebus_topic.test.name
  stream_analytics_job_name = azurerm_stream_analytics_output_servicebus_topic.test.stream_analytics_job_name
  resource_group_name       = azurerm_stream_analytics_output_servicebus_topic.test.resource_group_name
  topic_name                = azurerm_stream_analytics_output_servicebus_topic.test.topic_name
  servicebus_namespace      = azurerm_stream_analytics_output_servicebus_topic.test.servicebus_namespace
  shared_access_policy_key  = azurerm_stream_analytics_output_servicebus_topic.test.shared_access_policy_key
  shared_access_policy_name = azurerm_stream_analytics_output_servicebus_topic.test.shared_access_policy_name
  dynamic "serialization" {
    for_each = azurerm_stream_analytics_output_servicebus_topic.test.serialization
    content {
      encoding = lookup(serialization.value, "encoding", null)
      format   = lookup(serialization.value, "format", null)
      type     = serialization.value.type
    }
  }
}
