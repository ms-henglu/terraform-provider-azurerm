

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025936867521"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-240119025936867521"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctest-240119025936867521"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = true
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-240119025936867521"
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

  identity { type = "SystemAssigned" }
}


resource "azurerm_stream_analytics_output_servicebus_queue" "test" {
  name                      = "acctestinput-240119025936867521"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  queue_name                = azurerm_servicebus_queue.test.name
  servicebus_namespace      = azurerm_servicebus_namespace.test.name
  authentication_mode       = "Msi"

  serialization {
    type     = "Json"
    encoding = "UTF8"
    format   = "LineSeparated"
  }
}
