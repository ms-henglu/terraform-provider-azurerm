

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922062035586418"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-230922062035586418"
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


resource "azurerm_stream_analytics_output_powerbi" "test" {
  name                    = "acctestoutput-230922062035586418"
  stream_analytics_job_id = azurerm_stream_analytics_job.test.id
  dataset                 = "updated-dataset"
  table                   = "updated-table"
  group_id                = "e18ff5df-fb66-4f6d-8f27-88c4dcbfc002"
  group_name              = "some-updated-group-id"
}
