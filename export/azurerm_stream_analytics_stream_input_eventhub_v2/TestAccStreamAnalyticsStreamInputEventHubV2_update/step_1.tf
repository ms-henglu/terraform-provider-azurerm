

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127050201449316"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctestehn-230127050201449316"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteh-230127050201449316"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "test" {
  name                = "acctesteventhubcg-230127050201449316"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-230127050201449316"
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


resource "azurerm_eventhub_namespace" "updated" {
  name                = "acctestehn2-230127050201449316"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "updated" {
  name                = "acctesteh2-230127050201449316"
  namespace_name      = azurerm_eventhub_namespace.updated.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "updated" {
  name                = "acctesteventhubcg2-230127050201449316"
  namespace_name      = azurerm_eventhub_namespace.updated.name
  eventhub_name       = azurerm_eventhub.updated.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_stream_analytics_stream_input_eventhub_v2" "test" {
  name                         = "acctestinput-230127050201449316"
  stream_analytics_job_id      = azurerm_stream_analytics_job.test.id
  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.updated.name
  eventhub_name                = azurerm_eventhub.updated.name
  servicebus_namespace         = azurerm_eventhub_namespace.updated.name
  shared_access_policy_key     = azurerm_eventhub_namespace.updated.default_primary_key
  shared_access_policy_name    = "RootManageSharedAccessKey"
  partition_key                = "updatedPartitionKey"

  serialization {
    type = "Avro"
  }
}
