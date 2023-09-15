

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024316113684"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctestehn-230915024316113684"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteh-230915024316113684"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "test" {
  name                = "acctesteventhubcg-230915024316113684"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-230915024316113684"
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


resource "azurerm_stream_analytics_stream_input_eventhub" "test" {
  name                         = "acctestinput-230915024316113684"
  stream_analytics_job_name    = azurerm_stream_analytics_job.test.name
  resource_group_name          = azurerm_stream_analytics_job.test.resource_group_name
  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.test.name
  eventhub_name                = azurerm_eventhub.test.name
  servicebus_namespace         = azurerm_eventhub_namespace.test.name
  shared_access_policy_key     = azurerm_eventhub_namespace.test.default_primary_key
  shared_access_policy_name    = "RootManageSharedAccessKey"
  partition_key                = "partitionKey"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}
