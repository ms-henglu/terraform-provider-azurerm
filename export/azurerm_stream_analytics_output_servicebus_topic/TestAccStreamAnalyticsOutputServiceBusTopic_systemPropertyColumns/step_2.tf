

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034840925050"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-231016034840925050"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctest-231016034840925050"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = true
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-231016034840925050"
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
  name                      = "acctestinput-231016034840925050"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  topic_name                = azurerm_servicebus_topic.test.name
  servicebus_namespace      = azurerm_servicebus_namespace.test.name
  shared_access_policy_key  = azurerm_servicebus_namespace.test.default_primary_key
  shared_access_policy_name = "RootManageSharedAccessKey"

  serialization {
    type            = "Csv"
    encoding        = "UTF8"
    field_delimiter = ","
  }

  system_property_columns = {
    TimeToLive    = "100"
    Label         = "Test"
    CorrelationId = "79b839ac-be78-4542-8185-098170483986"
  }
}
