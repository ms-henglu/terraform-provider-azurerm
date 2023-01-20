

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120055214315221"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestiothub-230120055214315221"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-230120055214315221"
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


resource "azurerm_iothub" "updated" {
  name                = "acctestiot2-230120055214315221"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_stream_analytics_stream_input_iothub" "test" {
  name                         = "acctestinput-230120055214315221"
  stream_analytics_job_name    = azurerm_stream_analytics_job.test.name
  resource_group_name          = azurerm_stream_analytics_job.test.resource_group_name
  endpoint                     = "messages/events"
  eventhub_consumer_group_name = "$Default"
  iothub_namespace             = azurerm_iothub.updated.name
  shared_access_policy_key     = azurerm_iothub.updated.shared_access_policy[0].primary_key
  shared_access_policy_name    = "iothubowner"

  serialization {
    type = "Avro"
  }
}
