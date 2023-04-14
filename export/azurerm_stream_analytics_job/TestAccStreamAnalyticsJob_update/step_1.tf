
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414022311819192"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-230414022311819192"
  resource_group_name                      = azurerm_resource_group.test.name
  location                                 = azurerm_resource_group.test.location
  data_locale                              = "en-GB"
  compatibility_level                      = "1.1"
  events_late_arrival_max_delay_in_seconds = 10
  events_out_of_order_max_delay_in_seconds = 20
  events_out_of_order_policy               = "Drop"
  output_error_policy                      = "Stop"
  streaming_units                          = 6

  transformation_query = <<QUERY
    SELECT *
    INTO [SomeOtherOutputAlias]
    FROM [SomeOtherInputAlias]
QUERY

}
