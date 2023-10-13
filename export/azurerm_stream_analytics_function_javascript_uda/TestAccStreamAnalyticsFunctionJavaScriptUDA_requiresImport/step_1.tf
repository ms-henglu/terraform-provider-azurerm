


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013044400974474"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-231013044400974474"
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


resource "azurerm_stream_analytics_function_javascript_uda" "test" {
  name                    = "acctestinput-231013044400974474"
  stream_analytics_job_id = azurerm_stream_analytics_job.test.id

  script = <<SCRIPT
function main() {
    this.init = function () {
        this.state = 0;
    }

    this.accumulate = function (value, timestamp) {
        this.state += value;
    }

    this.computeResult = function () {
        return this.state;
    }
}
SCRIPT


  input {
    type = "bigint"
  }

  output {
    type = "bigint"
  }
}


resource "azurerm_stream_analytics_function_javascript_uda" "import" {
  name                    = azurerm_stream_analytics_function_javascript_uda.test.name
  stream_analytics_job_id = azurerm_stream_analytics_function_javascript_uda.test.stream_analytics_job_id
  script                  = azurerm_stream_analytics_function_javascript_uda.test.script

  input {
    type = azurerm_stream_analytics_function_javascript_uda.test.input.0.type
  }

  output {
    type = azurerm_stream_analytics_function_javascript_uda.test.output.0.type
  }
}
