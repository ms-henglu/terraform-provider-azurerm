


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025417715227"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccv8hmh"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestplan-v8hmh"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "test" {
  name                       = "acctestfunction-v8hmh"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
  os_type                    = "linux"
  version                    = "~3"
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-230825025417715227"
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


resource "azurerm_stream_analytics_output_function" "test" {
  name                      = "acctestoutput-230825025417715227"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  function_app              = azurerm_function_app.test.name
  function_name             = "somefunctionname"
  api_key                   = "test"
}


resource "azurerm_stream_analytics_output_function" "import" {
  name                      = azurerm_stream_analytics_output_function.test.name
  stream_analytics_job_name = azurerm_stream_analytics_output_function.test.stream_analytics_job_name
  resource_group_name       = azurerm_stream_analytics_output_function.test.resource_group_name
  function_app              = azurerm_stream_analytics_output_function.test.function_app
  function_name             = azurerm_stream_analytics_output_function.test.function_name
  api_key                   = azurerm_stream_analytics_output_function.test.api_key
}
