


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227180056818388"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-230227180056818388"
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


resource "azurerm_stream_analytics_function_javascript_udf" "test" {
  name                      = "acctestinput-230227180056818388"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name

  script = <<SCRIPT
function getRandomNumber(in) {
  return in;
}
SCRIPT


  input {
    type = "bigint"
  }

  output {
    type = "bigint"
  }
}


resource "azurerm_stream_analytics_function_javascript_udf" "import" {
  name                      = azurerm_stream_analytics_function_javascript_udf.test.name
  stream_analytics_job_name = azurerm_stream_analytics_function_javascript_udf.test.stream_analytics_job_name
  resource_group_name       = azurerm_stream_analytics_function_javascript_udf.test.resource_group_name
  script                    = azurerm_stream_analytics_function_javascript_udf.test.script

  input {
    type = azurerm_stream_analytics_function_javascript_udf.test.input.0.type
  }

  output {
    type = azurerm_stream_analytics_function_javascript_udf.test.output.0.type
  }
}
