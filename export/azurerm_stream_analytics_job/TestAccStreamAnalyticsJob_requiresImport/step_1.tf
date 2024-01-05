

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064732111134"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                = "acctestjob-240105064732111134"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  streaming_units     = 3

  tags = {
    environment = "Test"
  }

  transformation_query = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY

}


resource "azurerm_stream_analytics_job" "import" {
  name                                     = azurerm_stream_analytics_job.test.name
  resource_group_name                      = azurerm_stream_analytics_job.test.resource_group_name
  location                                 = azurerm_stream_analytics_job.test.location
  compatibility_level                      = azurerm_stream_analytics_job.test.compatibility_level
  data_locale                              = azurerm_stream_analytics_job.test.data_locale
  events_late_arrival_max_delay_in_seconds = azurerm_stream_analytics_job.test.events_late_arrival_max_delay_in_seconds
  events_out_of_order_max_delay_in_seconds = azurerm_stream_analytics_job.test.events_out_of_order_max_delay_in_seconds
  events_out_of_order_policy               = azurerm_stream_analytics_job.test.events_out_of_order_policy
  output_error_policy                      = azurerm_stream_analytics_job.test.output_error_policy
  streaming_units                          = azurerm_stream_analytics_job.test.streaming_units
  transformation_query                     = azurerm_stream_analytics_job.test.transformation_query
  tags                                     = azurerm_stream_analytics_job.test.tags
}
